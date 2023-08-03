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
alias autobootmainstatus='echo The autoboot status of the services is as follows appears in column left: ; \
systemctl list-unit-files | grep i2pd && systemctl list-unit-files | grep tor.service | grep -v lvm2-monitor.service | grep -v mdmonitor.service | grep -v systemd-network-generator.service && systemctl list-unit-files | grep bitcoind && systemctl list-unit-files | grep fulcrum && systemctl list-unit-files | grep btcrpcexplorer && systemctl list-unit-files | grep lnd && systemctl list-unit-files | grep thunderhub && systemctl list-unit-files | grep scb-backup'
alias systemonitor='htop'

# EXTRAS
alias showmainversion='echo The installed versions of the main services are as follows: ; \
  tor --version | grep version | grep -v compiled ; \
  echo `i2pd --version | grep version | grep -v Boost` ; \
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

alias showbonusversion='echo The installed versions of the bonus services are as follows: ; \
  circuitbreaker --version ; \
  echo RTL: `sudo head -n 3 /home/rtl/RTL/package.json | grep version` ; \
  bos -V ; \
  litd --lnd.version ; \
  lightning-cli --version ; \
  echo Electrs: `electrs --version` ; \
  lntop --version ; \
  sudo -u nym /home/nym/nym-socks5-client -V | grep nym ; \
  sudo -u nym /home/nym/nym-network-requester -V | grep nym ; \
  cloudflared --version ; \
  nostr-rs-relay -V'

alias manualscbackup='sudo touch /data/lnd/data/chain/bitcoin/mainnet/channel.backup'
alias manualtestnetbackup='sudo touch /data/lnd/data/chain/bitcoin/testnet/channel.backup'

# EXTRA LOGS
alias authlogs='sudo tail -f /var/log/auth.log'
alias sshlogslive='sudo tail -f /var/log/auth.log | grep sshd'
alias sshlogshistory='sudo tail --lines 500 /var/log/auth.log | grep sshd'

# NETWORK
alias whatsLISTEN='echo The follows services are listening: ; \
  sudo ss -tulpn | grep LISTEN'
alias publicip='echo Your public real IP is: ; \
    curl icanhazip.com'

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
alias startallmain='sudo systemctl start tor i2pd bitcoind fulcrum btcrpcexplorer lnd thunderhub scb-backup'

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
  sudo systemctl status tor i2pd bitcoind fulcrum btcrpcexplorer lnd thunderhub scb-backup ssh ufw nginx'

######################
# STOP MAIN SERVICES #
######################

alias stoptor='sudo systemctl stop tor'
alias stopi2p='sudo systemctl stop i2pd --no-block'
alias stopbitcoind='sudo systemctl stop bitcoind'
alias stopfulcrum='sudo systemctl stop fulcrum'
alias stopbtcrpcexplorer='sudo systemctl stop btcrpcexplorer'
alias stoplnd='sudo systemctl stop lnd'
alias stopthunderhub='sudo systemctl stop thunderhub'
alias stopscbackup='sudo systemctl stop scb-backup'
alias stopallmain='sudo systemctl stop btcrpcexplorer fulcrum scb-backup thunderhub bitcoind'

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
alias bitcoindlogs='sudo journalctl -f -u bitcoind.service'
alias fulcrumlogs='sudo journalctl -f -u fulcrum'
alias btcrpcexplorerlogs='sudo journalctl -f -u btcrpcexplorer'
alias lndlogs='sudo journalctl -f -u lnd'
alias thunderhublogs='sudo journalctl -f -u thunderhub'
alias scbackuplogs='sudo journalctl -f -u scb-backup'

##################
#       LND      #
##################

alias unlock='lncli unlock'
alias newaddress='lncli newaddress p2tr'
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
alias enablewireguard='sudo systemctl enable wg-quick@wg0'
alias enablenymrequester='sudo systemctl enable nym-network-requester'
alias enablenymsocks5='sudo systemctl enable nym-socks5-client'
alias enablenbx='sudo systemctl enable nbxplorer'
alias enablebtcpay='sudo systemctl enable btcpay'
alias enablecloudflared='sudo systemctl enable cloudflared'
alias enablenostrelay='sudo systemctl enable nostr-relay'
alias enableallbonus='sudo systemctl enable homer mempool circuitbreaker lnbits rtl litd cln electrs wg-quick@wg0 nym-network-requester nym-socks5-client btcpay nbxplorer cloudflared nostr-relay'

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
alias startwireguard='sudo systemctl start wg-quick@wg0'
alias startnymrequester='sudo systemctl start nym-network-requester'
alias startnymsocks5='sudo systemctl start nym-socks5-client'
alias startnbx='sudo systemctl start nbxplorer'
alias startbtcpay='sudo systemctl start btcpay'
alias startcloudflared='sudo systemctl start cloudflared'
alias startnostrelay='sudo systemctl start nostr-relay'

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
alias statuswireguard='sudo systemctl status wg-quick@wg0'
alias statusnymrequester='sudo systemctl status nym-network-requester'
alias statusnymsocks5='sudo systemctl status nym-socks5-client'
alias statusnbx='sudo systemctl status nbxplorer'
alias statusbtcpay='sudo systemctl status btcpay'
alias statuscloudflared='sudo systemctl status cloudflared'
alias statusnostrelay='sudo systemctl status nostr-relay'
alias statusallbonus='echo The status of the bonus services is as follows, press the space key to advance: ; \
  sudo systemctl status homer mempool circuitbreaker lnbits rtl litd cln electrs wg-quick@wg0 nym-network-requester nym-socks5-client btcpay nbxplorer cloudflared nostr-relay'

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
alias stopwireguard='sudo systemctl stop wg-quick@wg0'
alias stopnymrequester='sudo systemctl stop nym-network-requester'
alias stopnymsocks5='sudo systemctl stop nym-socks5-client'
alias stopnbx='sudo systemctl stop nbxplorer'
alias stopbtcpay='sudo systemctl stop btcpay'
alias stopcloudflared='sudo systemctl stop cloudflared'
alias stopnostrelay='sudo systemctl stop nostr-relay'
alias stopallbonus='sudo systemctl stop homer mempool circuitbreaker lnbits rtl litd cln electrs wg-quick@wg0 nym-socks5-client nym-network-requester btcpay nbxplorer cloudflared nostr-reay'

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
alias disablewireguard='sudo systemctl disable wg-quick@wg0'
alias disablenymrequester='sudo systemctl disable nym-network-requester'
alias disablenymsocks5='sudo systemctl disable nym-socks5-client'
alias disablenbx='sudo systemctl disable nbxplorer'
alias disablebtcpay='sudo systemctl disable btcpay'
alias disablecloudflared='sudo systemctl disable cloudflared'
alias disablenostrelay='sudo systemctl disable nostr-relay'
alias disableallbonus='sudo systemctl disable homer mempool circuitbreaker lnbits rtl litd cln electrs wg-quick@wg0 nym-network-requester nym-socks5-client btcpay nbxplorer cloudflared nostr-relay'

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
alias wireguardlogs='sudo journalctl -f -u wg-quick@wg0'
alias nymrequesterlogs='sudo journalctl -f -u nym-network-requester'
alias nymsocks5logs='sudo journalctl -f -u nym-socks5-client'
alias nbxlogs='sudo journalctl -f -u nbxplorer'
alias btcpaylogs='sudo journalctl -f -u btcpay'
alias cloudflaredlogs='sudo journalctl -f -u cloudflared'
alias nostrelaylogs='sudo journalctl -f -u nostr-relay'

#################
#  LND TESTNET  #
#################
alias lntestunlock='lncli --network testnet unlock'
alias lntestnewaddress='lncli --network testnet newaddress p2tr'
alias lntesttxns='lncli --network testnet listchaintxns'
alias lntestlistpayments='lncli --network testnet listpayments'
alias lntestlistinvoices='lncli --network testnet listinvoices'
alias lntestgetinfo='lncli --network testnet getinfo'
alias lntestwalletbalance='lncli --network testnet walletbalance'
alias lntestpeers='lncli --network testnet listpeers'
alias lntestchannels='lncli --network testnet listchannels'
alias lntestchannelbalance='lncli --network testnet channelbalance'
alias lntestpendingchannels='lncli --network testnet pendingchannels'
alias lntestopenchannel='lncli --network testnet openchannel'
alias lntestconnect='lncli --network testnet connect'
alias lntestpayinvoice='lncli --network testnet payinvoice'
alias lntestaddinvoice='lncli --network testnet addinvoice'
alias lntestaddAMPinvoice30d='lncli --network testnet addinvoice --amp'

##########################
# LND Testnet Watchtower #
##########################
alias lntestwtclientinfo='lncli --network testnet wtclient towers'
alias lntestwtserverinfo='lncli --network testnet tower info'
