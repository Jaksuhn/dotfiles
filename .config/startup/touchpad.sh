#!/bin/bash
# enable-naturalscrolling
#  Enable natural scrolling for all registered pointers
#
# Depends: libinput - all input devices should be managed through libinput!
#
# Copyright (C) 2016 Jan Christoph Ebersbach
#
# http://www.e-jc.de/
#
# All rights reserved.
#
# The source code of this program is made available
# under the terms of the GNU Affero General Public License version 3
# (GNU AGPL V3) as published by the Free Software Foundation.
#
# Binary versions of this program provided by Univention to you as
# well as other copyrighted, protected or trademarked materials like
# Logos, graphics, fonts, specific documentations and configurations,
# cryptographic keys etc. are subject to a license agreement between
# you and Univention and not subject to the GNU AGPL V3.
#
# In the case you use this program under the terms of the GNU AGPL V3,
# the program is provided in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License with the Debian GNU/Linux or Univention distribution in file
# /usr/share/common-licenses/AGPL-3; if not, see
# <http://www.gnu.org/licenses/>.

# https://github.com/jceb/bin/blob/6ed30a0b3ef5c9733aabf3d9be9079d6f705308d/naturalscrolling

set -u
set -e

if [ $# -ge 1 ] && ([ "${1}" = '-h' ] || [ "${1}" = '--help' ]); then
    echo -e "$(basename "${0}") [-v] [0|1]\n\tEnable (1, default) or disable (0) natural scrolling\n\t-v Verbose output"
    exit
fi

verbose=
if [ $# -ge 1 ] && [ "${1}" = '-v' ]; then
    verbose=1
    shift
fi

action=1
action_verbose='Enabling'
if [ $# -ge 1 ] && [ "${1}" = '0' ]; then
    action=0
    action_verbose='Disabling'
fi

# list all input devices: xinput
# list properties of input device: xinput list-props <ID>
# set property: xinput set-prop <ID> <PROP_ID> <VALUE>


xinput | sed -ne 's/.*id=\([0-9]\+\).*\[slave \+pointer.*/\1/p' | while read id; do
    if [ -n "${verbose}" ]; then
        echo "Considering device $(xinput list-props ${id} | sed -ne '1s/Device //;s/:$//p') (${id})"
    fi
    nat_scroll="$(xinput list-props "${id}" | grep 'Natural Scrolling Enabled (' | sed -ne 's/.*(\([0-9]\+\)):.*/\1/p')"
    if [ -n "${nat_scroll}" ]; then
        echo "${action_verbose} natural scrolling (${nat_scroll}) for device ${id}."
        xinput set-prop "${id}" "${nat_scroll}" "${action}"
    else
        # workaround for synaptics touchpads
        nat_scroll="$(xinput list-props "${id}" | grep 'Synaptics Scrolling Distance (' | sed -ne 's/.*(\([0-9]\+\)):.*/\1/p')"
        hrz_scroll="$(xinput list-props "${id}" | grep 'Synaptics Two-Finger Scrolling (' | sed -ne 's/.*(\([0-9]\+\)):.*/\1/p')"
        tap_action="$(xinput list-props "${id}" | grep 'Synaptics Tap Action (' | sed -ne 's/.*(\([0-9]\+\)):.*/\1/p')"

        if [ -n "${nat_scroll}" ]; then
            values="$(xinput list-props "${id}" | grep 'Synaptics Scrolling Distance (' | sed -ne 's/.*:\s*-\?\([0-9]\+\),\s*-\?\([0-9]\+\)[^0-9]*/\1 \2/p')"
            if [ -n "${values}" ]; then
                v1="$(echo "${values}" | sed -ne 's/ .*//p')"
                v2="$(echo "${values}" | sed -ne 's/.* //p')"
                a=""
                if [ "${action}" = "1" ]; then
                    a="-"
                fi
                echo "${action_verbose} natural scrolling (${nat_scroll}) for device ${id}."
                xinput set-prop "${id}" "${nat_scroll}" "${a}${v1}" "${a}${v2}"
            elif [ -n "${verbose}" ]; then
                echo 'Natural scrolling not available.'
            fi
        elif [ -n "${verbose}" ]; then
            echo 'Natural scrolling not available.'
        fi

        if [ -n "${hrz_scroll}" ]; then
            values="$(xinput list-props "${id}" | grep 'Synaptics Two-Finger Scrolling (' | sed -ne 's/.*:\s*-\?\([0-9]\+\),\s*-\?\([0-9]\+\)[^0-9]*/\1 \2/p')"
            if [ -n "${values}" ]; then
                echo "${action_verbose} horizontal scrolling (${hrz_scroll}) for device ${id}."
                xinput set-prop "${id}" "${hrz_scroll}" 1, 1
            elif [ -n "${verbose}" ]; then
                echo 'Horizontal scrolling not available.'
            fi
        elif [ -n "${verbose}" ]; then
            echo 'Horizontal scrolling not available.'
        fi

        if [ -n "${tap_action}" ]; then
            values="$(xinput list-props "${id}" | grep 'Synaptics Tap Action (' | sed -ne 's/.*:\s*-\?\([0-9]\+\),\s*-\?\([0-9]\+\)[^0-9]*/\1 \2/p')"
            if [ -n "${values}" ]; then
                echo "${action_verbose} tap actions (${tap_action}) for device ${id}."
                xinput set-prop "${id}" "${tap_action}" 0, 0, 0, 0, 1, 3, 2
            elif [ -n "${verbose}" ]; then
                echo 'Tap actions not available.'
            fi
        elif [ -n "${verbose}" ]; then
            echo 'Tap actions not available.'
        fi
    fi
done
