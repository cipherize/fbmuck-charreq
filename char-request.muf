@program cmd-char-request.muf
1 99999 d
i
( BEGIN CONFIGURABLES )

$def dataobj           prog
$def datapropdir       "@charreq"
$def code-charset      "abcdefghijklmnopqrstuvwxyzABCDEEFGHIJKLMNOPQRSTUVWXYZ0123456789"
$def code-length       16
$def expiration-time   1440 ( minutes )

( END CONFIGURABLES )

$include $lib/case
$include $lib/timestr

$def streq stringcmp not
$def dataprop datapropdir "/" strcat swap strcat "/" strcat
$def guest? me @ "GUEST" flag?
$def check-player-exists pmatch #-1 =
$def show-aup me @ "news aup" force
$def msg_good "bold,green" textattr
$def msg_warn "bold,yellow" textattr
$def msg_error "bold,red" textattr

$define gen-verification-code
  { 1 code-length 1 for pop code-charset random code-charset strlen % 1 + 1 midstr repeat }join
$enddef

lvar args
lvar name
lvar email
lvar name_loop
lvar entry_type
lvar entry_value

: ban-email-add
  me @ "Not implemented." notify exit
;

: ban-email-del
  me @ "Not implemented." notify exit
;

: ban-email-list
  me @ "Not implemented." notify exit
;

: get-req-array
  { dataobj "requests" dataprop array_get_propdirs foreach
    nip dup dataobj swap "requests" dataprop swap strcat array_get_propvals "token" array_insertitem
  repeat } array_make
;

: purge-request
  dup "token" array_getitem dataobj swap "requests" dataprop swap strcat remove_prop
;

: check-expired
  "exptime" array_getitem systime < if 1 else 0 then
;

( Check if there is an existing, valid request for vaule s2 of type s1 )
( s1 can be "name" or "email" )
: check-request ( s1 s2 -- b )
  entry_value ! entry_type !
  get-req-array foreach
    nip dup entry_type @ array_getitem entry_value @ streq if
      dup check-expired if
        purge-request
        0 exit
      else
        pop 1 exit
      then
    else
      pop
    then
  repeat 0
;

: check-email-block
  me @ "Not implemented." notify exit
;

( s1 is email, s2 is name, b is true - things went okay or false - things bonk)
: gen-request ( s1 s2 -- b )
  { -rot gen-verification-code systime expiration-time 60 * + }list dup "," array_join userlog
  array_vals pop swap "requests" dataprop swap strcat -4 rotate
  { -4 rotate "email" -4 rotate "name" -rot "exptime" swap }dict prog -rot array_put_propvals
  1
;

: new-request
  { "===== Character Creation =====" msg_good
    "What is your email address?"
    "NOTE: You must be able to receive email at this address." msg_warn } array_make
  { me @ } array_make array_notify read

  ( email @ check-email-block if )
  (  me @ "Requests from that email address are not accepted. Please page a wizard for assistance." msg_error notify exit )
  ( then )

  dup "email" swap check-request if
    pop me @ "There is already a pending request for that email address. Please page a wizard for assistance." msg_error notify exit
  then

  begin
    me @ "What name would you like?" notify read
    dup pmatch if
      pop me @ "A player already exists with that name." msg_error notify 0
    else
      dup "name" swap check-request if
        pop me @ "A request for that name already exists." msg_error notify 0
      else
        1
      then
    then

    not if
      me @ "Would you like to try another name?" notify read
      "y*" smatch not if
        me @ "Please run " command @ strcat " to try again, or page a wizard for assistance." strcat notify exit
      else
        0
      then
    else
      1
    then
  until

  show-aup

  me @ "Do you agree to abide by the terms of the Acceptable Use Policy?" notify read

  "y*" smatch not if
    me @ "As you have not accepted the terms of the AUP, your request has been cancelled." notify exit
  then

  gen-request

  if
    { "Your request has been submitted." msg_good
      "An email will be sent to the address you provided with instructions to complete your request."
      "Be aware that this request will expire in " expiration-time 60 * ltimestr strcat ". Please check your spam folder, just in case!" strcat msg_warn
    }list { me @ }list array_notify
  else
    me @ "There was an error generating your request. Please page a wizard for assistance." msg_error notify
  then
;

: verify-request
  args @ " " split nip " " split "requests" dataprop swap dup -4 rotate strcat prog swap array_get_propvals
  dup not if
    me @ "Either there is not an active request for that name or the verification code you've provided is invalid." msg_error notify
    me @ "Please check your email to confirm the character name and verification code and try again, or page a wizard for assistance." msg_warn notify
  else
    dup "name" array_getitem 3 pick stringcmp if
      me @ "Either there is not an active request for that name or the verification code you've provided is invalid." msg_error notify
      me @ "Please check your email to confirm the character name and verification code and try again, or page a wizard for assistance." msg_warn notify
    else
      "email" array_getitem swap

      begin
        me @ "Please choose a password for your new character and enter it now." msg_warn notify read
        me @ "Please confirm your new password." msg_warn notify read
        over strcmp if
          me @ "The passwords that you have entered do not match. Please try again." msg_error notify pop 0
        else
          1
        then
      until

      me @ "Creating new character and logging you in..." msg_good notify
      ( dup -rot newplayer swap descr -rot descr_setuser )
      dup -rot newplayer dup 4 rotate 2 dupn
      "@/email" swap setprop "@/wemail" swap setprop
      prog "requests" dataprop depth rotate strcat "/" strcat remove_prop
      descr -rot swap descr_setuser
    then
  then
;

: do-help
  0 pop
;

: main
  dup args ! " " split pop

  case
    "" stringcmp not when new-request end
    "#verify" stringcmp not when verify-request end
    "#banadd" stringcmp not when ban-email-add end
    "#bandel" stringcmp not when ban-email-del end
    "#banlist" stringcmp not when ban-email-list end
    default do-help end
  endcase
;
.
c
q
