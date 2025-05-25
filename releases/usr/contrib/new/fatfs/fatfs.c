/* V7/x86 source code: see www.nordier.com/v7x86 for details. */
/* Copyright (c) 1996 Robert Nordier.  All rights reserved. */

#include <sys/types.h>
#include <sys/stat.h>
#include <ctype.h>
#include <time.h>
#include <stdio.h>
#include <stdint.h>

extern char *index(), *malloc(), *rindex(), *strcat();
extern struct tm *localtime();

#define strchr(x,y)   index(x,y)
#define strrchr(x,y)  rindex(x,y)

#define CV2(p) ((uint16_t)(p)[0] |         \
               ((uint16_t)(p)[1] << 010))

#define CV4(p) ((uint32_t)(p)[0] |          \
               ((uint32_t)(p)[1] << 010) |  \
               ((uint32_t)(p)[2] << 020) |  \
               ((uint32_t)(p)[3] << 030))

#define MK2(p, u)                  \
{                                  \
   (p)[0] = (uint8_t)(u);           \
   (p)[1] = (uint8_t)((u) >> 010);  \
}

#define MK4(p, u)                  \
{                                  \
   (p)[0] = (uint8_t)(u);           \
   (p)[1] = (uint8_t)((u) >> 010);  \
   (p)[2] = (uint8_t)((u) >> 020);  \
   (p)[3] = (uint8_t)((u) >> 030);  \
}

#define SECSIZ  512             /* sector size */
#define FATS      2             /* number of FATs */
#define DEPS     16             /* directory entries per sector */

#define DENMSZ    8             /* DE name size */
#define DEXTSZ    3             /* DE extension size */

#define FA_LABEL  0x08          /* file attribute: label */
#define FA_DIR    0x10          /* file attribute: directory */
#define FA_ARCH   0x20          /* file attribute: archive */

#define FATOFS(fat12, c)  ((uint32_t)(c) + ((fat12) ? (c) >> 1 : (c)))


typedef struct {
    uint8_t secsiz[2];           /* sector size */
    uint8_t spc;                 /* sectors per cluster */
    uint8_t ressec[2];           /* reserved sectors */
    uint8_t fats;                /* FATs */
    uint8_t dirents[2];          /* root directory entries */
    uint8_t secs[2];             /* total sectors */
    uint8_t media;               /* media descriptor */
    uint8_t spf[2];              /* sectors per FAT */
    uint8_t spt[2];              /* sectors per track */
    uint8_t heads[2];            /* drive heads */
    uint8_t hidsec[4];           /* hidden sectors */
    uint8_t lsecs[4];            /* huge sectors */
} BPB;

typedef struct {
    uint8_t jmp[3];              /* usually 80x86 'jmp' opcode */
    uint8_t oem[8];              /* OEM name and version */
    BPB bpb;                    /* BPB */
    uint8_t drive;               /* drive number */
    uint8_t reserved;            /* reserved */
    uint8_t extsig;              /* extended boot signature */
    uint8_t volid[4];            /* volume ID */
    uint8_t label[11];           /* volume label */
    uint8_t fstype[8];           /* file system type */
} BS;

typedef struct {
    uint8_t name[8];             /* name */
    uint8_t ext[3];              /* extension */
    uint8_t attr;                /* attributes */
    uint8_t reserved[10];        /* reserved */
    uint8_t time[2];             /* time */
    uint8_t date[2];             /* date */
    uint8_t clus[2];             /* starting cluster */
    uint8_t size[4];             /* file size */
} DE;

typedef struct {
    uint8_t *fat;                /* FAT */
    DE *dir;                    /* root directory */
    uint32_t lsnfat;              /* logical sector number: fat */
    uint32_t lsndir;              /* logical sector number: dir */
    uint32_t lsndta;              /* logical sector number: data area */
    int fd;                     /* file descriptor */
    int fat12;                  /* 12-bit FAT entries */
    uint16_t spf;                /* sectors per fat */
    uint16_t dirents;            /* root directory entries */
    uint16_t spc;                /* sectors per cluster */
    uint16_t xclus;              /* maximum cluster number */
} DP;

char *progname;

char *fat_date(), *catpath(), *alloc();
DE *lookup(), *de_look();
uint8_t *nxname();
uint16_t getfat();

int
main(argc, argv)
char **argv;
{
    static char *argst[] = {
        "[fat_file]",
        "fat_file [file]",
        "file [fat_file]"
    };
    DP dp;
    char *s;
    int i;

    if ((s = strrchr(argv[0], '/')) != NULL)
        s++;
    else
        s = argv[0];
    progname = s;
    i = strcmp(s, "fatput") ? strcmp(s, "fatget") ? 0 : 1 : 2;
    if (argc < 3 - !i || argc > 4 - !i) {
        fprintf(stderr, "usage: %s filesystem %s\n", s, argst[i]);
        return 1;
    }
    fat_open(&dp, argv[1], i == 2);
    switch (i) {
    default:
        i = fatdir(&dp, argv[2]);
        break;
    case 1:
        i = fatget(&dp, argv[2], argv[3]);
        break;
    case 2:
        i = fatput(&dp, argv[2], argv[3]);
    }
    fat_close(&dp);
    return i;
}

int
fatdir(dp, name)
DP *dp;
char *name;
{
    DE *de;
    unsigned i;

    if (name) {
        if (!(de = lookup(dp, name)))
            return 1;
        de_print(de);
    } else
        for (i = 0; i < dp->dirents && *dp->dir[i].name; i++)
            if (*dp->dir[i].name != 0xe5 &&
                !(dp->dir[i].attr & FA_LABEL))
                de_print(dp->dir + i);
    return 0;
}

int
fatget(dp, source, target)
DP *dp;
char *source;
char *target;
{
    struct stat st;
    DE *de;
    char *fn;
    char *buf;
    uint32_t cnt;
    int d;
    uint16_t len;
    uint16_t clus;

    if (!(de = lookup(dp, source)))
        return 1;
    if (de->attr & FA_DIR) {
        warn("%s: Cannot copy directories", source);
        return 1;
    }
    if (target)
        if (!stat(target, &st) && (st.st_mode & S_IFMT) == S_IFDIR)
            fn = catpath(target, source);
        else
            fn = target;
    else
        fn = source;
    if ((d = creat(fn, 0666)) == -1) {
        warn("s: Cannot create file", fn);
        return 1;
    }
    len = dp->spc * SECSIZ;
    buf = alloc(len);
    clus = CV2(de->clus);
    for (cnt = CV4(de->size); cnt; cnt -= len) {
        fat_read(dp, buf, dp->lsndta + (uint32_t) (clus - 2) * dp->spc,
                 dp->spc);
        if (len > cnt)
            len = cnt;
        if (write(d, buf, len) != len) {
            warn("%s: Write error", fn);
            return 1;
        }
        clus = getfat(dp, clus);
    }
    if (close(d)) {
        warn("%s: I/O error", fn);
        return 1;
    }
    return 0;
}

int
fatput(dp, source, target)
DP *dp;
char *source;
char *target;
{
    struct stat st;
    uint8_t *nx;
    DE *de;
    char *buf;
    uint32_t size;
    int d;
    uint16_t dd, dt;
    uint16_t len;
    uint16_t cnt;
    uint16_t clus;
    uint16_t i;

    if (stat(source, &st) == -1) {
        warn("%s: Cannot stat", source);
        return 1;
    }
    if ((st.st_mode & S_IFMT) != S_IFREG) {
        warn("%s: Not a regular file", source);
        return 1;
    }
    if ((d = open(source, 0)) == -1) {
        warn("%s: Cannot open", source);
        return 1;
    }
    if (!target)
        if ((target = strrchr(source, '/')) != NULL)
            target++;
        else
            target = source;
    if (!(nx = nxname(target)))
        return 1;
    if ((de = de_look(dp, nx)) != NULL) {
        warn("%s: File already exists", target);
        return 1;
    }
    for (i = 0; i < dp->dirents; i++)
        if (!*dp->dir[i].name || *dp->dir[i].name == 0xe5) {
            de = dp->dir + i;
            break;
        }
    if (!de) {
        warn("No directory space");
        return 1;
    }
    memset(de, 0, sizeof(DE));
    memcpy(de->name, nx, DENMSZ + DEXTSZ);
    de->attr = FA_ARCH;
    time_utod(st.st_mtime, &dd, &dt);
    MK2(de->time, dt);
    MK2(de->date, dd);
    len = dp->spc * SECSIZ;
    buf = alloc(len);
    size = 0;
    clus = 0;
    while ((cnt = read(d, buf, len)) != 0) {
        if (cnt == (uint16_t) - 1)
            error("%s: Read error", source);
        for (i = clus ? clus + 1 : 2;
             i <= dp->xclus && getfat(dp, i);
             i++);
        if (i > dp->xclus) {
            warn("Not enough space");
            return 1;
        }
        if (clus)
            setfat(dp, clus, i);
        else
            MK2(de->clus, i);
        clus = i;
        fat_write(dp, buf, dp->lsndta + (uint32_t) (clus - 2) * dp->spc,
                  dp->spc);
        size += cnt;
    }
    if (size) {
        setfat(dp, clus, dp->fat12 ? 0xfff : 0xffff);
        MK4(de->size, size);
        fat_sync(dp, CV2(de->clus));
    }
    fat_write(dp, dp->dir + (de - dp->dir & ~(DEPS - 1)),
              dp->lsndir + (de - dp->dir) / DEPS, 1);
    return 0;
}

de_print(de)
DE *de;
{
    unsigned i;

    putchar(*de->name == 5 ? 0xe5 : *de->name);
    for (i = 1; i < DENMSZ; i++)
        putchar(de->name[i]);
    printf("  ");
    for (i = 0; i < DEXTSZ; i++)
        putchar(de->ext[i]);
    printf("  ");
    if (de->attr & FA_DIR)
        printf("<DIR>     ");
    else
        printf("%10lu", CV4(de->size));
    printf("  %s\n", fat_date(CV2(de->date), CV2(de->time)));
}

DE *
lookup(dp, name)
DP *dp;
char *name;
{
    DE *de;
    uint8_t *nx;

    if (!(nx = nxname(name)))
        return NULL;
    if (!(de = de_look(dp, nx)))
        warn("%s: No such file or directory", name);
    return de;
}

uint8_t *
nxname(name)
char *name;
{
    static uint8_t nx[DENMSZ + DEXTSZ];

    if (de_namex(nx, name)) {
        warn("%s: Invalid filename", name);
        return NULL;
    }
    return nx;
}

int
de_namex(nx, name)
uint8_t *nx;
char *name;
{
    int i;

    memset(nx, ' ', DENMSZ + DEXTSZ);
    for (i = 0; i < DENMSZ && fat_char(*name); i++)
        nx[i] = upper(*name++);
    if (i && *name == '.') {
        name++;
        for (i = 0; i < DEXTSZ && fat_char(*name); i++)
            nx[DENMSZ + i] = upper(*name++);
    }
    if (nx[0] == 0xe5)
        nx[0] = 5;
    return nx[0] == ' ' || *name;
}

DE *
de_look(dp, nx)
DP *dp;
uint8_t *nx;
{
    unsigned i;

    for (i = 0; i < dp->dirents && *dp->dir[i].name; i++)
        if (*dp->dir[i].name != 0xe5 &&
            !(dp->dir[i].attr & FA_LABEL) &&
            !memcmp(dp->dir[i].name, nx, DENMSZ + DEXTSZ))
            return dp->dir + i;
    return NULL;
}

fat_open(dp, fs, rdwr)
DP *dp;
char *fs;
{
    char buf[SECSIZ];
    BS *bs = (BS *) buf;
    uint32_t sc;

    if ((dp->fd = open(fs, rdwr ? 2 : 0)) < 0)
        error("%s: Cannot open", fs);
    fat_read(dp, buf, 0, 1);
    if (bs->jmp[0] != 0xe9 &&
        (bs->jmp[0] != 0xeb || bs->jmp[2] != 0x90) ||
        bs->bpb.media < 0xf0 ||
        CV2(bs->bpb.secsiz) != SECSIZ ||
        !bs->bpb.spc || (bs->bpb.spc ^ bs->bpb.spc - 1) < bs->bpb.spc)
        error("%s: Not a FAT filesystem", fs);
    dp->spf = CV2(bs->bpb.spf);
    dp->dirents = CV2(bs->bpb.dirents);
    dp->spc = bs->bpb.spc;
    sc = CV2(bs->bpb.secs);
    if (!sc && bs->extsig == 0x29)
        sc = CV4(bs->bpb.lsecs);
    if (!sc || bs->bpb.fats != FATS || dp->dirents & DEPS - 1 ||
        dp->spc > 64)
        error("%s: Unsupported filesystem parameters", fs);
    dp->lsnfat = CV2(bs->bpb.ressec);
    dp->lsndir = dp->lsnfat + dp->spf * FATS;
    dp->lsndta = dp->lsndir + dp->dirents / DEPS;
    sc = (sc - dp->lsndta) / dp->spc;
    dp->fat12 = sc < 0xff6;
    if (sc > 0xfff5 ||
        dp->spf < (FATOFS(dp->fat12, sc + 1) + SECSIZ) / SECSIZ)
        error("%s: Invalid filesystem parameters", fs);
    dp->xclus = sc + 1;
    dp->fat = (uint8_t *)alloc((uint32_t) dp->spf * SECSIZ);
    dp->dir = (DE *)alloc((uint32_t) dp->dirents / DEPS * SECSIZ);
    fat_read(dp, dp->fat, dp->lsnfat, dp->spf);
    fat_read(dp, dp->dir, dp->lsndir, dp->dirents / DEPS);
}

fat_close(dp)
DP *dp;
{
    if (close(dp->fd))
        error("close error");
}

uint16_t
getfat(dp, c)
DP *dp;
uint16_t c;
{
    uint16_t x;

    x = CV2(dp->fat + FATOFS(dp->fat12, c));
    return dp->fat12 ? c & 1 ? x >> 4 : x & 0xfff : x;
}

setfat(dp, c, x)
DP *dp;
uint16_t c;
uint16_t x;
{
    uint32_t i;
    uint16_t e;

    i = FATOFS(dp->fat12, c);
    e = dp->fat12 ? CV2(dp->fat + i) & (c & 1 ? 0xf : 0xf000) : 0;
    MK2(dp->fat + i, e | (dp->fat12 && c & 1 ? x << 4 : x));
}

fat_sync(dp, start_c)
DP *dp;
uint16_t start_c;
{
    uint32_t i;
    uint16_t out;
    uint16_t c;
    uint16_t sec;
    uint16_t cpy;

    out = 0xffff;
    for (c = start_c; c >= 2 && c <= dp->xclus; c = getfat(dp, c)) {
        i = FATOFS(dp->fat12, c);
        for (sec = i / SECSIZ; sec <= (i + 1) / SECSIZ; sec++)
            if (out != sec) {
                for (cpy = 0; cpy < FATS; cpy++)
                    fat_write(dp, dp->fat + sec * SECSIZ,
                              dp->lsnfat + dp->spf * cpy + sec, 1);
                out = sec;
            }
    }
}

fat_read(dp, buf, sec, cnt)
DP *dp;
char *buf;
uint32_t sec;
uint16_t cnt;
{
    if (lseek(dp->fd, sec * SECSIZ, 0) == -1 ||
        read(dp->fd, buf, cnt * SECSIZ) != cnt * SECSIZ)
        error("Read error");
}

fat_write(dp, buf, sec, cnt)
DP *dp;
char *buf;
uint32_t sec;
uint16_t cnt;
{
    if (lseek(dp->fd, sec * SECSIZ, 0) == -1 ||
        write(dp->fd, buf, cnt * SECSIZ) != cnt * SECSIZ)
        error("Write error");
}

int
fat_char(c)
{
    return c & 0x80 || c >= ' ' && !strchr("\"*+,./:;<=>?[\\]|", c);
}

char *
fat_date(ddate, dtime)
uint16_t ddate;
uint16_t dtime;
{
    static char mth[12][4] = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    };
    static char buf[32];
    uint16_t dy, dm, dd, th, tm;

    dy = 80 + (ddate >> 9);
    dm = ((ddate >> 5) & 0xf) - 1;
    dd = ddate & 0x1f;
    th = dtime >> 11;
    tm = (dtime >> 5) & 0x3f;
    if (dy > 99 || dm > 11)
        dy = 80, dm = 0, dd = 1, th = 0, tm = 0;
    sprintf(buf, "%02u-%3s-%02u  %02u:%02u", dd, mth[dm], dy, th, tm);
    return buf;
}

time_utod(timer, d, t)
long timer;
uint16_t *d;
uint16_t *t;
{
    struct tm *tm;

    tm = localtime(&timer);
    *d = ((uint16_t) tm->tm_year - 80) << 9 |
        ((uint16_t) tm->tm_mon + 1) << 5 |
        (uint16_t) tm->tm_mday;
    *t = (uint16_t) tm->tm_hour << 11 |
        (uint16_t) tm->tm_min << 5 |
        (uint16_t) tm->tm_sec >> 1;
}

char *
catpath(p0, p1)
char *p0;
char *p1;
{
    char *p;

    p = alloc(strlen(p0) + strlen(p1) + 2);
    return strcat(strcat(strcpy(p, p0), "/"), p1);
}

char *
alloc(sz)
unsigned sz;
{
    char *p;

    if ((p = malloc(sz)) == NULL)
	error("No core");
    return p;
}

int
upper(c)
{
    return islower(c) ? toupper(c) : c;
}

error(fmt, err)
char *fmt;
{
    warn(fmt, err);
    exit(1);
}

warn(fmt, arg)
char *fmt;
{
    fprintf(stderr, "%s: ", progname);
    fprintf(stderr, fmt, arg);
    fputc('\n', stderr);
}
