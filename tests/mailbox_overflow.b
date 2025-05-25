GET "LIBHDR"
GET "mailbox.bh"

LET START() = VALOF
$( LET mb = CreateMailbox(2)
   FOR I = 1 TO 3 DO
       IF SendMessage(mb, I)
         THEN WRITEF("sent %N*N", I)
         ELSE WRITEF("overflow %N*N", I)
   FOR I = 1 TO 2 DO
       LET msg = ReceiveMessage(mb, 1)
       WRITEF("recv %N*N", msg)
   RESULTIS 0
$)
