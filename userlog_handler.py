#!/usr/bin/env python3

import re
import smtplib
import sys

from email.message import EmailMessage
from datetime import datetime
from dateutil import tz

# Set this to the path of the fbmuck user log.
filepath = '/opt/fuzzball/furocity/game/logs/user'

# Change this to the dbref of char-request.muf.
prog_id = '#209'

# Change this multiline string to whatever works for you. The following tokens are needed:
# $$$NAME$$$ - The requested character name.
# $$$TOKEN$$$ - The generated verification token.
# $$$TIME$$$ - Time stamp for when the request expires.
template = """Thank you for joining us at Furocity!

In order to complete the character creation process, please enter the following into your guest session:

   @request #verify $$$NAME$$$ $$$TOKEN$$$

If you have already disconnected, please reconnect as a guest and enter the above command.

The system will prompt you to set a password, then automatically reconnect you to your new character.

This request will expire on $$$TIME$$$.

Please let a wizard know if you have any issues. Thank you, and again, welcome."""

user_log = re.compile(
    r"^(?:\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}): (?:\S+\(#\d+\)) \[(?:\S+?)\((?P<prog>#\d+?)\)\]: (?P<email>.*?@.*?),(?P<name>\S+?),(?P<token>[A-Za-z0-9]+?),(?P<exptime>\d+?)$"
)

if __name__ == "__main__":
    with open(filepath, 'r') as fh:
        log_entry = user_log.match(fh.readlines()[-1])

    if not log_entry:
        sys.exit()

    if log_entry.group('prog') != prog_id:
        sys.exit()

    email = log_entry.group('email')
    name = log_entry.group('name')
    token = log_entry.group('token')
    exptime = int(log_entry.group('exptime'))

    expdate = datetime.fromtimestamp(exptime, tz=tz.UTC)
    expdstr = expdate.strftime("%A, %B %d, %Y at %I:%M:%S %Z")

    msg_content = (
        template.replace("$$$NAME$$$", name)
        .replace("$$$TOKEN$$$", token)
        .replace("$$$TIME$$$", expdstr)
    )

    # Set the subject and From address.
    msg = EmailMessage()
    msg["Subject"] = f"Furocity Character Request Verification for {name}"
    msg["From"] = "noreply@altair.furocity.io"
    msg["To"] = email
    msg.set_content(msg_content)

    # Set this appropriately. I assume you're using a local postfix deployment.
    s = smtplib.SMTP("localhost")
    s.send_message(msg)
    s.quit()