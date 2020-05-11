#######################################################################################################
## currency.tcl 1.0  (25/03/2020)  			  Copyright 2008 - 2020 @ WwW.TCLScripts.NET ##
##                        _   _   _   _   _   _   _   _   _   _   _   _   _   _                      ##
##                       / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \                     ##
##                      ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )                    ##
##                       \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/                     ##
##                                                                                                   ##
##                                      ® BLaCkShaDoW Production ®                                   ##
##                                                                                                   ##
##                                              PRESENTS                                             ##
##									                           ® ##
############################################  Currency TCL   ##########################################
##									                             ##
##  DESCRIPTION: 							                             ##
##  An utility to convert currencies. A list of currencies is available in tcl.		             ##
##  												     ##
##			                            						     ##
##  Tested on Eggdrop v1.8.4 (Debian Linux 3.16.0-4-amd64) Tcl version: 8.6.10                       ##
##									                             ##
#######################################################################################################
##									                             ##
##                                 /===============================\                                 ##
##                                 |      This Space For Rent      |                                 ##
##                                 \===============================/                                 ##
##									                             ##
#######################################################################################################
##									                             ##
##  INSTALLATION: 							                             ##
##     ++ http package is REQUIRED for this script to work.                           		     ##
##     ++ json package is REQUIRED for this script to work.		                             ##
##     ++ Edit the currency.tcl script and place it into your /scripts directory,                    ##
##     ++ add "source scripts/currency.tcl" to your eggdrop config and rehash the bot.               ##
##									                             ##
#######################################################################################################
#######################################################################################################
##									                             ##
##  OFFICIAL LINKS:                                                                                  ##
##   E-mail      : BLaCkShaDoW[at]tclscripts.net                                                     ##
##   Bugs report : http://www.tclscripts.net                                                         ##
##   GitHub page : https://github.com/tclscripts/ 			                             ##
##   Online help : irc://irc.undernet.org/tcl-help                                                   ##
##                 #TCL-HELP / UnderNet        	                                                     ##
##                 You can ask in english or romanian                                                ##
##									                             ##
##     paypal.me/DanielVoipan = Please consider a donation. Thanks!                                  ##
##									                             ##
#######################################################################################################
##									                             ##
##                           You want a customised TCL Script for your eggdrop?                      ##
##                                Easy-peasy, just tell me what you need!                            ##
##                I can create almost anything in TCL based on your ideas and donations.             ##
##                  Email blackshadow@tclscripts.net or info@tclscripts.net with your                ##
##                    request informations and I'll contact you as soon as possible.                 ##
##									                             ##
#######################################################################################################
##												     ##
##  Commmands:									                     ##
##	!conv <currency> ; it will convert the <currency> in the default currency set 		     ##			
##	!conv <currency> [value] ; it will convert the value specified of <currency> to the default  ##
##	!conv <from_currency> <to_currency> ; it will convert <from_currency> to to_currency         ##
##	!conv <from_currency> <to_currency> [value] ;it will convert <from_currency> to <to_currency>##
##                                                                                                   ##
##  Settings: .chanset/.set #chan +currency - enable the !cur command	                             ##
##            							                                     ##
##                                                                                                   ##
##            .chanset/.set #chan default-currency <currency - setup the default currency            ##
##												     ##
#######################################################################################################
#######################################################################################################
##									                             ##
##  LICENSE:                                                                                         ##
##   This code comes with ABSOLUTELY NO WARRANTY.                                                    ##
##                                                                                                   ##
##   This program is free software; you can redistribute it and/or modify it under the terms of      ##
##   the GNU General Public License version 3 as published by the Free Software Foundation.          ##
##                                                                                                   ##
##   This program is distributed WITHOUT ANY WARRANTY; without even the implied warranty of          ##
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                                            ##
##   USE AT YOUR OWN RISK.                                                                           ##
##                                                                                                   ##
##   See the GNU General Public License for more details.                                            ##
##        (http://www.gnu.org/copyleft/library.txt)                                                  ##
##                                                                                                   ##
##  			          Copyright 2008 - 2020 @ WwW.TCLScripts.NET                         ##
##                                                                                                   ##
#######################################################################################################
#######################################################################################################
##                                   CONFIGURATION FOR Currency TCL                                  ##
#######################################################################################################

#Set default currency
##
set currency(default_currency) "EUR"

#Set flags for using the !ex command
##
set currency(flags) "-|-"

###
# FLOOD PROTECTION
#Set the number of requests within specifide number of seconds to trigger flood protection.
# By default, 4:10, which allows for upto 3 queries in 10 seconds. 4 or more quries in 10 seconds would cuase
# the forth and later queries to be ignored for the amount of time specifide above.
###
set currency(flood_prot) "3:10"

###
# FLOOD PROTECTION
#Set the number of minute(s) to ignore flooders
###
set currency(ignore_prot) "1"


#The list with currencies available
##
set currency(valid_currencys) {
"CAD"
"HKD"
"ISK"
"PHP"
"DKK"
"HUF"
"CZK"
"GBP"
"RON"
"SEK"
"IDR"
"INR"
"BRL"
"RUB"
"HRK"
"JPY"
"THB"
"CHF"
"USD"
"EUR"
"MYR"
"BGN"
"TRY"
"CNY"
"NOK"
"NZD"
"ZAR"
"MXN"
"SGD"
"AUD"
"ILS"
"KRW"
"PLN"
}

########################################################################################################
#
#					The ENd :-)
#
#######################################################################################################

bind pub $currency(flags) !conv currency:cmd

setudef str default-currency
setudef flag currency

package require http
package require json

###
proc currency:valid_currency {curr} {
	global currency
	
if {$curr == ""} { return 0 }
if {[lsearch -nocase $currency(valid_currencys) $curr] > -1} {
	return 1
} else {
	return 0
	}
}

###
proc currency:cmd {nick host hand chan arg} {
	global currency
if {![channel get $chan currency]} {
	return
}
	set flood_protect [currency:flood:prot $chan $host]
if {$flood_protect == "1"} {
	set get_seconds [currency:get:flood_time $host $chan]
	putserv "NOTICE $nick :Flood protection enabled. Please wait $get_seconds seconds."
	return
}
	set from [string toupper [lindex [split $arg] 1]]
	set to [string toupper [lindex [split $arg] 0]]
	set value [lindex [split $arg] 2]
	set output ""
	set valid_to [currency:valid_currency $to]
	set valid_from [currency:valid_currency $from]
if {$valid_to == "0"} { puthelp "NOTICE $nick :Invalid <from> currency, please read the currency list." ; return }
if {$valid_from == "0" && ![regexp {^[0-9]} $from]} {
	set currency_set [channel get $chan default-currency]
if {$currency_set == ""} {
	set from [string toupper $currency(default_currency)]
	} else {
	set from [string toupper $currency_set]
	}
} elseif {[regexp {^[0-9]} $from]} {
	set value $from
	set currency_set [channel get $chan default-currency]
if {$currency_set == ""} {
	set from [string toupper $currency(default_currency)]
	} else {
	set from [string toupper $currency_set]
	}
} elseif {$valid_from == "0"} {
	set currency_set [channel get $chan default-currency]
if {$currency_set == ""} {
	set from [string toupper $currency(default_currency)]
	} else {
	set from [string toupper $currency_set]
	}
}
if {$value != ""} {
if {![regexp {^[0-9]} $value]} {
	puthelp "NOTICE $nick :Invalid <value> specified, please use a number."	
	return
	}
} else { set value 1 }
if {[string equal -nocase $from $to]} { putserv "NOTICE $nick :The <from> currency is the same with <to> currency. Choose another one"
	return
}
	set data [currency:data $to]
if {$data == "-1"} {
	puthelp "NOTICE $nick :Data not available. Try again later."
	return
}
	set rates [currency:getjson "rates" $data]
	set split_values [split $rates " "]
	set find [lsearch -nocase $split_values "$from"]
	set value_for_one [lindex $split_values [expr $find + 1]]
	set output [expr $value_for_one * $value]
	set calc [expr double(round(10000*$output))/10000]
	set date [currency:getjson "date" $data]
	putserv "PRIVMSG $chan :-= CONVERT =- From: \002$to\002 ; Value: \002$calc\002 \002$from\002 (1 $to = $value_for_one $from) ; Currency Date: $date"
}

###
#http://wiki.tcl.tk/5000
proc fixpoint {varName script} {
    upvar 1 $varName arg
    while {[set res [uplevel 1 $script]] ne $arg} {
        set arg $res
    }
    return $arg
}

###
proc commify {num {sep .}} {
    fixpoint num {
        regsub {^([-+]?\d+)(\d\d\d)} $num "\\1$sep\\2"
    }
}


set currency(name) "Currency TCL"
set currency(owner) "BLaCkShaDoW"
set currency(site) "WwW.TclScripts.Net"
set currency(version) "1.0"


###
proc currency:data {base} {
	global currency
	set link "http://blackexchange.000webhostapp.com/?base=$base"
	#http::register https 443 [list ::tls::socket -tls1 1]
	set ipq [http::config -useragent "lynx"]
	set ipq [::http::geturl "$link" -timeout 10000]
	set status [::http::status $ipq]
if {$status != "ok"} { 
	::http::cleanup $ipq
	return -1 
}
	set data [http::data $ipq]
	::http::cleanup $ipq
	return $data
}


###
proc currency:getjson {get data} {
	global translate
	set parse [::json::json2dict $data]
	set return ""
foreach {name info} $parse {
if {[string equal -nocase $name $get]} {
	set return $info
	break;
		}
	}
	return $return
}


###
proc currency:flood:prot {chan host} {
	global currency
	set number [scan $currency(flood_prot) %\[^:\]]
	set timer [scan $currency(flood_prot) %*\[^:\]:%s]
if {[info exists currency(flood:$host:$chan:act)]} {
	return 1
}
foreach tmr [utimers] {
if {[string match "*currency:remove:flood $host $chan*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
	}
}
if {![info exists currency(flood:$host:$chan)]} { 
	set currency(flood:$host:$chan) 0 
}
	incr currency(flood:$host:$chan)
	utimer $timer [list currency:remove:flood $host $chan]	
if {$currency(flood:$host:$chan) > $number} {
	set currency(flood:$host:$chan:act) 1
	utimer 60 [list currency:expire:flood $host $chan]
	return 1
	} else {
	return 0
	}
}

###
proc currency:expire:flood {host chan} {
	global currency
if {[info exists currency(flood:$host:$chan:act)]} {
	unset currency(flood:$host:$chan:act)
	}
}

###
proc currency:remove:flood {host chan} {
	global currency
if {[info exists currency(flood:$host:$chan)]} {
	unset currency(flood:$host:$chan)
	}
}

###
proc currency:get:flood_time {host chan} {
	global currency
		foreach tmr [utimers] {
if {[string match "*currency:expire:flood $host $chan*" [join [lindex $tmr 1]]]} {
	return [lindex $tmr 0]
		}
	}
}


putlog "$currency(name) $currency(version) TCL by $currency(owner) loaded. For more tcls visit -- $currency(site) --"

