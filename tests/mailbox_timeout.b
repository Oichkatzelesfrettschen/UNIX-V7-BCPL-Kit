GET "LIBHDR"
GET "mailbox.bh"

LET START() = VALOF
$( LET mb = CreateMailbox(1)
   LET r = ReceiveMessage(mb, 2)
   IF r = MB_TIMEOUT
        THEN WRITEF("timeout*N")
        ELSE WRITEF("recv %N*N", r)
   RESULTIS 0
$)
