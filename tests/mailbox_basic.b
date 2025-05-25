GET "LIBHDR"
GET "mailbox.bh"

LET START() = VALOF
$( LET mb = CreateMailbox(4)
   SendMessage(mb, 10)
   SendMessage(mb, 20)
   LET m1 = ReceiveMessage(mb, 1)
   LET m2 = ReceiveMessage(mb, 1)
   WRITEF("basic %N %N*N", m1, m2)
   RESULTIS 0
$)
