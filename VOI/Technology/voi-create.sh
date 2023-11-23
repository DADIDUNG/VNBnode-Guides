#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

# Logo
sleep 1 && curl -s https://raw.githubusercontent.com/vnbnode/VNBnode-Guides/main/logo.sh | bash && sleep 1

# Create wallet or Recovery wallet
echo -e "\e[1m\e[32m6. Create wallet or Recovery wallet... \e[0m" && sleep 1
SelectVersion="Please choose: \n 1. Create wallet (Gives you 60 seconds to save the seed wallet)\n 2. Recovery wallet"
echo -e "${SelectVersion}"
read -p "Enter index: " version;
if [ "$version" != "2" ];then
	goal wallet new $walletname
    sleep 60
else
	goal wallet new -r $walletname
fi
sleep 1

# To create a new account or Recovery account
echo -e "\e[1m\e[32m7. Create wallet or Recovery wallet... \e[0m" && sleep 1
SelectVersion="Please choose: \n 1. Create account (Gives you 60 seconds to save the address wallet)\n 2. Recovery account"
echo -e "${SelectVersion}"
read -p "Enter index: " version;
if [ "$version" != "2" ];then
	goal account new
    sleep 60
else
	goal wallet import
fi
sleep 1

# Goal account export
echo -e "\e[1m\e[32m7. Goal account export... \e[0m" && sleep 1
echo -ne "\nEnter your voi address (Gives you 60 seconds to save the seed account: " && read addr &&\
goal account export -a $addr
sleep 60

# Generate your participation keys
echo -e "\e[1m\e[32m7. Generate your participation keys... \e[0m" && sleep 1
getaddress() {
  if [ "$addr" == "" ]; then echo -ne "\nNote: Completing this will remember your address until you log out. "; else echo -ne "\nNote: Using previously entered address. "; fi; echo -e "To forget the address, press Ctrl+C and enter the command:\n\tunset addr\n";
  count=0; while ! (echo "$addr" | grep -E "^[A-Z2-7]{58}$" > /dev/null); do
    if [ $count -gt 0 ]; then echo "Invalid address, please try again."; fi
    echo -ne "\nEnter your voi address: "; read addr;
    addr=$(echo "$addr" | sed 's/ *$//g'); count=$((count+1));
  done; echo "Using address: $addr"
}
getaddress &&\
echo -ne "\nEnter duration in rounds [Fill: 8000000 and ENTER)]: " && read duration &&\
start=$(goal node status | grep "Last committed block:" | cut -d\  -f4) &&\
duration=${duration:-2000000} &&\
end=$((start + duration)) &&\
dilution=$(echo "sqrt($end - $start)" | bc) &&\
goal account addpartkey -a $addr --roundFirstValid $start --roundLastValid $end --keyDilution $dilution
sleep 1

# Check your participation status
echo -e "\e[1m\e[32m8. Check your participation status... \e[0m" && sleep 1
getaddress() {
  if [ "$addr" == "" ]; then echo -ne "\nNote: Completing this will remember your address until you log out. "; else echo -ne "\nNote: Using previously entered address. "; fi; echo -e "To forget the address, press Ctrl+C and enter the command:\n\tunset addr\n";
  count=0; while ! (echo "$addr" | grep -E "^[A-Z2-7]{58}$" > /dev/null); do
    if [ $count -gt 0 ]; then echo "Invalid address, please try again."; fi
    echo -ne "\nEnter your voi address: "; read addr;
    addr=$(echo "$addr" | sed 's/ *$//g'); count=$((count+1));
  done; echo "Using address: $addr"
}
getaddress &&\
goal account dump -a $addr | jq -r 'if (.onl == 1) then "You are online!" else "You are offline." end'

cd $HOME
rm $HOME/voi-create.sh

# Please Faucet
echo -e "\e[1;32mLink faucet: \e[0m\e[1;36mhttps://discord.gg/voinetwork\e[0m"