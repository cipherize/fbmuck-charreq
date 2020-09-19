@program con-guest-stuff.muf
1 99999 d
i
$include $lib/case

: main
    me @ "@/guest?" getpropstr "y*" smatch if
        case
            "Disconnect" stringcmp 0 = when me @ dup getlink moveto end
            "Connect"    stringcmp 0 = when
                me @ "Welcome to Furocity! To create a character, enter " "bold,green" textattr
                "@request" "bold,cyan" textattr strcat
                " to get started." "bold,green" textattr strcat notify
            end
        endcase
    then
;
.
c
q