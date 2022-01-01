;CancelBot 3.0

on 1:START:{
  %cancelbot.scriptroot = $+($mircdir,cancelbot)
  %cancelbot.bibleroot = $+($mircdir,cancelbot\bibles)
  %cancelbot.versionfile = versions.txt
  %cancelbot.helpfile = help.txt
  %cancelbot.rulesfile = rules.txt
  %cancelbot.service = true
  %cancelbot.advertise = true
  %cancelbot.advertisein = #christiandebate #christian
  %cancelbot.advertisetext = BibleBot is online. Serving acv akjv amp apo asv bbe bom dict dar dou greek heb hebrew hnv kjv kjv+ nasb niv nkjv quran rot rsv strongs web ylt yng vulgate.
  %cancelbot.autovoice = false
  %cancelbot.autovoicein = #christiandebate #cancelbot
  ;%cancelbot.verselimit = 3
  ;%cancelbot.locallimit = 10
  %cancelbot.versioncolor = 1
  %cancelbot.bookcolor = 4
  %cancelbot.versenumbercolor = 12
  %cancelbot.versecolor = 1
  %cancelbot.cleanup = true
  %cancelbot.cleanuptime = 30
  %cancelbot.badwordswatch = true
  %cancelbot.badwordstext = That kind of language is not allowed!
  %cancelbot.badwordstimeout = 600
  %cancelbot.badwords = bitch asshole shit fuck stfu cunt 

  var %versions = $+(%cancelbot.scriptroot,\,%cancelbot.versionfile)
  ;ini file format with section [versions] 1 if you are serving the bible 0 if not or remove line
  hload -smNi VERSIONS %versions versions
  echo 9 $+ $hget(VERSIONS) loaded  
  echo 9CancelBot script root %cancelbot.scriptroot
  echo 9CancelBot bible root %cancelbot.bibleroot
  echo 9CancelBot 3.0 locked and loaded!

  if (%cancelbot.cleanup == true) {
    var %minutes = $calc(%cancelbot.cleanuptime *60)
    timercleanup 0 %minutes close -m
  }
}

;Channel text
on 1:TEXT:!rules:#:{
  var %rulesfile = $+(%cancelbot.scriptroot,\,%cancelbot.rulesfile)
  play $nick %rulesfile
}

on 1:TEXT:!help:#:{
  var %helpfile = $+(%cancelbot.scriptroot,\,%cancelbot.helpfile)
  play $nick %helpfile
}

on 1:TEXT:!versions:#:{
  var %versionfile = $+(%cancelbot.scriptroot,\,%cancelbot.versionfile)
  play $nick %versionfile
}

;channel service
on 1:TEXT:*:#:{
  ;bible service
  if (%cancelbot.service == true) {
    ;see if the first word is a version we have
    var %version = $hget(VERSIONS, $1)
    if (%version == 1) {
      var %bookverse = $getBibleVerse($1, $2, $3)
      if (%bookverse != $null) {
        msg $chan %cancelbot.versioncolor $+ $1 %cancelbot.bookcolor $+ $2 %cancelbot.versenumbercolor $3 $+ %cancelbot.versecolor $+ : %bookverse
      }
    }
  }

  ;badwords watch
  if (%cancelbot.badwordswatch == true) {
    var %count $gettok(%cancelbot.badwords,0,32)
    while (%count > 0) {
      var %badword = $gettok(%cancelbot.badwords,%count,32)
      if (%badword isin $1-) {
        ;mode $chan +b $address($nick,2)
        ;kick $chan $nick
        ban -ku%cancelbot.badwordstimeout $chan $nick 2 %cancelbot.badwordskicktext
      }
      dec %count
    }
  }

}

;query service
on 1:TEXT:*:?:{
  if (%cancelbot.service == true) {
    ;see if the first word is a version we have
    var %version = $hget(VERSIONS, $1)
    if (%version == 1) {
      var %bookverse = $getBibleVerse($1, $2, $3)
      if (%bookverse != $null) {
        msg $nick %cancelbot.versioncolor $+ $1 %cancelbot.bookcolor $+ $2 %cancelbot.versenumbercolor $3 $+ %cancelbot.versecolor $+ : %bookverse
      }
    }
  }
}

;advertise + voice
on 1:JOIN:#:{
  if (%cancelbot.advertise == true &&  $chan isin %cancelbot.advertisein && %cancelbot.service == true) {
    notice $nick %cancelbot.advertisetext
  }

  if (%cancelbot.autovoice == true && $chan isin %cancelbot.autovoicein) {
    mode $chan +v $nick
  }
}

;routines
alias getBibleVerse {
  var %biblepath = $+(%cancelbot.bibleroot,\,$1)
  ;echo version found %biblepath

  ;see if the second word is a book in the version we have
  var %bookpath = $+(%biblepath,\,$2)

  ;echo book found %bookpath $isfile(%bookpath)
  if ($isfile(%bookpath) == $true) {
    var %bookverse = $read(%bookpath,s,$3)
    ;if a verse is returned
    if ($readn > 0) {
      return %bookverse
    }
  }
}

alias serviceOn {
  %cancelbot.service = true
  echo CancelBot Bible has been turned 9ON
}

alias serviceOff {
  %cancelbot.service = false
  echo CancelBot Bible has been turned 4OFF
}

alias advertiseOn {
  %cancelbot.advertise = true
  echo CancelBot Advertise Bible has been turned 9ON
}

alias advertiseOff {
  %cancelbot.advertise = false
  echo CancelBot Advertise Bible has been turned 4OFF
}

alias badwordswatchOn {
  %cancelbot.badwordswatch = true
  echo CancelBot Bad Words has been turned 9ON
}

alias badwordswatchOff {
  %cancelbot.badwordswatch = false
  echo CancelBot Bad Words has been turned 4OFF
}

alias autovoiceOn {
  %cancelbot.autovoice = true
  echo CancelBot Auto Voice has been turned 9ON
}

alias autovoiceOff {
  %cancelbot.autovoice = false
  echo CancelBot Auto Voice has been turned 4OFF
}

alias bibleQuote {
  var %version = $hget(VERSIONS, $1)
  if (%version == 1) {
    var %bookverse = $getBibleVerse($1, $2, $3)
    if (%bookverse != $null) {
      msg $chan %cancelbot.versioncolor $+ $1 %cancelbot.bookcolor $+ $2 %cancelbot.versenumbercolor $3 $+ %cancelbot.versecolor $+ : %bookverse
    }
  }
}

alias bibleLookup {
  var %version = $hget(VERSIONS, $1)
  if (%version == 1) {
    var %bookverse = $getBibleVerse($1, $2, $3)
    if (%bookverse != $null) {
      echo %cancelbot.versioncolor $+ $1 %cancelbot.bookcolor $+ $2 %cancelbot.versenumbercolor $3 $+ %cancelbot.versecolor $+ : %bookverse
    }
  }
}

;menu items
menu Channel {
  CancelBot 3.0
  .Bible Status $iif(%cancelbot.service == true, On, Off)
  .Bible ON:$serviceOn
  .Bible OFF:$serviceOff
  .-
  .Bible Advertise $iif(%cancelbot.advertise == true, On, Off)
  .Bible Advertise ON:$advertiseOn
  .Bible Advertise OFF:$advertiseOff
  .-
  .Bad Words Status $iif(%cancelbot.badwordswatch == true, On, Off)
  .Bad Words Watch ON:$badwordswatchOn
  .Bad Words Watch OFF:$badwordswatchOff
  .-
  .Auto Voice Status $iif(%cancelbot.autovoice == true, On, Off)
  .Auto Voice ON:$autovoiceOn
  .Auto Voice OFF:$autovoiceOff
}
