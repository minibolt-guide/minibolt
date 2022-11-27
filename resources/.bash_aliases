# MiniBolt: aliases
# /resources/.bash_aliases

###########################
# GENERAL STATUS & OTHERS #
###########################

# SYSTEM
alias update='sudo apt update'
alias listupgradable='sudo apt list --upgradable'
alias upgrade='sudo apt -u -V upgrade'
alias fullcheckupgrade='sudo apt update && sudo apt list --upgradable && sudo apt -u -V upgrade'
alias systemonitor='bpytop'
alias networkmonitor='sudo iftop'
alias autobootmainstatus='echo The autoboot status of the services is as follows appears in column left: ; \
systemctl list-unit-files | grep i2pd && systemctl list-unit-files | grep tor.service | grep -v lvm2-monitor.service | grep -v mdmonitor.service | grep -v systemd-network-generator.service && systemctl list-unit-files | grep bitcoind && systemctl list-unit-files | grep fulcrum && systemctl list-unit-files | grep btcrpcexplorer && systemctl list-unit-files | grep lnd && systemctl list-unit-files | grep thunderhub'

alias showmainversion='echo The installed versions of the main services are as follows: ; \
  tor --version | grep version | grep -v compiled ; \
  echo `i2pd --version | grep version` ; \
  echo `bitcoind --version | grep version` ; \
  Fulcrum --version | grep Fulcrum ; \
  echo BTC RPC Explorer: `sudo head -n 3 /home/btcrpcexplorer/btc-rpc-explorer/package.json | grep version` ; \
  lnd --version ; \
  echo Thunderhub: `sudo head -n 3 /home/thunderhub/thunderhub/package.json | grep version` ; \
  echo NodeJS: `node -v`; \
  echo NPM: v`npm --version` ; \
  htop --version ; \
  ots --version ; \
  nginx -v'

# EXTRAS
alias showbonusversion='echo The installed versions of the bonus services are as follows: ; \
  circuitbreaker --version ; \
  echo RTL: `sudo head -n 3 /home/rtl/RTL/package.json | grep version` ; \
  bos -V ; \
  litd --lnd.version ; \
  lightning-cli --version ; \
  echo Electrs: `electrs --version` ; \
  bpytop --version ; \
  lntop --version'

alias fail2banreport='sudo fail2ban-client status sshd'
alias testscb-backup='sudo touch /data/lnd/data/chain/bitcoin/mainnet/channel.backup'

# EXTRA LOGS
alias authlogs='sudo tail -f /var/log/auth.log'
alias ufwlogs='sudo tail -f /var/log/ufw.log'
alias sshlogslive='sudo tail -f /var/log/auth.log | grep sshd'
alias sshlogshistory='sudo tail --lines 500 /var/log/auth.log | grep sshd'
alias fail2banlogs='sudo tail -f /var/log/fail2ban.log'

# NETWORK
alias whatsLISTEN='echo The follows services are listening: ; \
  sudo ss -tulpn | grep LISTEN'
alias publicip='echo Your public real IP is: ; \
    curl icanhazip.com'
alias torcheck='echo Checking Tor in your host... ; \
  curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations | xargs ; \
  echo Attention: This advice is really to check if you have correctly installed Tor in your host. If not appear anything it means that you need to install Tor with command: sudo apt install tor'

################
# MAIN SECTION #
################

########################
# ENABLE MAIN SERVICES #
########################

alias enabletor='sudo systemctl enable tor'
alias enablei2p='sudo systemctl enable i2pd'
alias enablebitcoind='sudo systemctl enable bitcoind'
alias enablefulcrum='sudo systemctl enable fulcrum'
alias enablebtcrpcexplorer='sudo systemctl enable btcrpcexplorer'
alias enablelnd='sudo systemctl enable lnd'
alias enablethunderhub='sudo systemctl enable thunderhub'
alias enablescbackup='sudo systemctl enable scb-backup'
alias enableallmain='sudo systemctl enable tor i2pd bitcoind fulcrum btcrpcexplorer lnd thunderhub scb-backup'

#######################
# START MAIN SERVICES #
#######################

alias startor='sudo systemctl start tor'
alias starti2p='sudo systemctl start i2pd'
alias startbitcoind='sudo systemctl start bitcoind'
alias startfulcrum='sudo systemctl start fulcrum'
alias startbtcrpcexplorer='sudo systemctl start btcrpcexplorer'
alias startlnd='sudo systemctl start lnd'
alias starthunderhub='sudo systemctl start thunderhub'
alias startscbackup='sudo systemctl start scb-backup'

#######################
# SERVICE MAIN STATUS #
#######################

alias statustor='sudo systemctl status tor'
alias statusi2p='sudo systemctl status i2pd'
alias statusbitcoind='sudo systemctl status bitcoind'
alias statusfulcrum='sudo systemctl status fulcrum'
alias statusbtcrpcexplorer='sudo systemctl status btcrpcexplorer'
alias statuslnd='sudo systemctl status lnd'
alias statusthunderhub='sudo systemctl status thunderhub'
alias statuscbackup='sudo systemctl status scb-backup'
alias statusallmain='echo The status of the main services is as follows, press the space key to advance: ; \
  sudo systemctl status tor i2pd bitcoind fulcrum btcrpcexplorer lnd thunderhub scb-backup ssh ufw nginx fail2ban'

######################
# STOP MAIN SERVICES #
######################

alias stoptor='sudo systemctl stop tor'
alias stopi2p='sudo systemctl stop i2pd'
alias stopbitcoind='sudo systemctl stop bitcoind'
alias stopfulcrum='sudo systemctl stop fulcrum'
alias stopbtcrpcexplorer='sudo systemctl stop btcrpcexplorer'
alias stoplnd='sudo systemctl stop lnd'
alias stopthunderhub='sudo systemctl stop thunderhub'
alias stopscbackup='sudo systemctl stop scb-backup'
alias stopallmain='sudo systemctl stop btcrpcexplorer fulcrum scb-backup thunderhub lnd bitcoind'

#########################
# DISABLE MAIN SERVICES #
#########################

alias disabletor='sudo systemctl disable tor'
alias disablei2p='sudo systemctl disable i2pd'
alias disablebitcoind='sudo systemctl disable bitcoind'
alias disablefulcrum='sudo systemctl disable fulcrum'
alias disablebtcrpcexplorer='sudo systemctl disable btcrpcexplorer'
alias disablelnd='sudo systemctl disable lnd'
alias disablethunderhub='sudo systemctl disable thunderhub'
alias disablescbackup='sudo systemctl disable scb-backup'
alias disableallmain='sudo systemctl disable bitcoind fulcrum btcrpcexplorer lnd thunderhub scb-backup'

######################
# MAIN SERVICES LOGS #
######################

alias torlogs='sudo journalctl -f -u tor@default'
alias i2plogs='sudo tail -f /var/log/i2pd/i2pd.log'
alias bitcoindlogs='sudo tail -f /home/bitcoin/.bitcoin/debug.log'
alias fulcrumlogs='sudo journalctl -f -u fulcrum'
alias btcrpcexplorerlogs='sudo journalctl -f -u btcrpcexplorer'
alias lndlogs='sudo journalctl -f -u lnd'
alias thunderhublogs='sudo journalctl -f -u thunderhub'
alias scbackuplogs='sudo journalctl -f -u scb-backup'

##################
#       LND      #
##################

alias unlock='lncli unlock'
alias newaddress='lncli newaddress p2wkh'
alias txns='lncli listchaintxns'
alias listpayments='lncli listpayments'
alias listinvoices='lncli listinvoices'
alias getinfo='lncli getinfo'
alias walletbalance='lncli walletbalance'
alias peers='lncli listpeers'
alias channels='lncli listchannels'
alias channelbalance='lncli channelbalance'
alias pendingchannels='lncli pendingchannels'
alias openchannel='lncli openchannel'
alias connect='lncli connect'
alias payinvoice='lncli payinvoice'
alias addinvoice='lncli addinvoice'
alias addAMPinvoice30d='lncli addinvoice --amp'

##################
# LND Watchtower #
##################

alias wtclientinfo='lncli wtclient towers'
alias wtserverinfo='lncli tower info'

#################
# BONUS SECTION #
#################

#########################
# ENABLE BONUS SERVICES #
#########################

alias enablehomer='sudo systemctl enable homer'
alias enablemempool='sudo systemctl enable mempool'
alias enablecircuitbreaker='sudo systemctl enable circuitbreaker'
alias enablelnbits='sudo systemctl enable lnbits'
alias enablertl='sudo systemctl enable rtl'
alias enablelitd='sudo systemctl enable litd'
alias enablecln='sudo systemctl enable cln'
alias enablelectrs='sudo systemctl enable electrs'
alias enableallbonus='sudo systemctl enable homer mempool circuitbreaker lnbits rtl litd cln electrs'

########################
# START BONUS SERVICES #
########################

alias starthomer='sudo systemctl start homer'
alias startmempool='sudo systemctl start mempool'
alias startcircuitbreaker='sudo systemctl start circuitbreaker'
alias startlnbits='sudo systemctl start lnbits'
alias startrtl='sudo systemctl start rtl'
alias startlitd='sudo systemctl start litd'
alias startcln='sudo systemctl start cln'
alias startelectrs='sudo systemctl start electrs'

#########################
# STATUS BONUS SERVICES #
#########################

alias statushomer='sudo systemctl status homer'
alias statusmempool='sudo systemctl status mempool'
alias statuscircuitbreaker='sudo systemctl status circuitbreaker'
alias statuslnbits='sudo systemctl status lnbits'
alias statusrtl='sudo systemctl status rtl'
alias statuslitd='sudo systemctl status litd'
alias statuscln='sudo systemctl status cln'
alias statuselectrs='sudo systemctl status electrs'
alias statusallbonus='echo The status of the bonus services is as follows, press the space key to advance: ; \
  sudo systemctl status homer mempool circuitbreaker lnbits rtl litd cln electrs'

#######################
# STOP BONUS SERVICES #
#######################

alias stophomer='sudo systemctl stop homer'
alias stopmempool='sudo systemctl stop mempool'
alias stopcircuitbreaker='sudo systemctl stop circuitbreaker'
alias stoplnbits='sudo systemctl stop lnbits'
alias stoprtl='sudo systemctl stop rtl'
alias stoplitd='sudo systemctl stop litd'
alias stopcln='sudo systemctl stop cln'
alias stopelectrs='sudo systemctl stop electrs'
alias stopallbonus='sudo systemctl stop homer mempool circuitbreaker lnbits rtl litd cln electrs'

##########################
# DISABLE BONUS SERVICES #
##########################

alias disablehomer='sudo systemctl disable homer'
alias disablemempool='sudo systemctl disable mempool'
alias disablecircuitbreaker='sudo systemctl disable circuitbreaker'
alias disablelnbits='sudo systemctl disable lnbits'
alias disablertl='sudo systemctl disable rtl'
alias disablelitd='sudo systemctl disable litd'
alias disablecln='sudo systemctl disable cln'
alias disablelectrs='sudo systemctl disable electrs'
alias disableallbonus='sudo systemctl disable homer mempool circuitbreaker lnbits rtl litd cln electrs'

#######################
# BONUS SERVICES LOGS #
#######################

alias homerlogs='sudo journalctl -f -u homer'
alias mempoollogs='sudo journalctl -f -u mempool'
alias circuitbreakerlogs='sudo journalctl -f -u circuitbreaker'
alias lnbitslogs='sudo journalctl -f -u lnbits'
alias rtlogs='sudo journalctl -f -u rtl'
alias litdlogs='sudo journalctl -f -u litd'
alias clnlogs='sudo journalctl -f -u cln'
alias electrslogs='sudo journalctl -f -u electrs'
