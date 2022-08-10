set -e
dir=$(dirname $0)

################# Parse arguments #################
create=false
setup=false
new_accounts=false
fund_accounts=false
fund_amount=50ether
stake_amount=1000000gwei
new_game=false

while true; do
    case "$1" in 
        --create) # create the smart contracts in the blockchain
            create=true
            shift
            ;;
        --setup) # Setups the contracts to their initial state, e.g. ownership transfer
            setup=true
            shift
            ;;
        --new_accounts) # creates a new pair of random accounts and private keys
            new_accounts=true
            shift
            ;;
        --fund_accounts) # transfers ether from default account to created accounts
            fund_accounts=true
            shift
            ;;
        --fund_amount) # two-parameter argument, e.g. `--fund_amount 50ether`
            shift
            fund_amount=$1
            shift
            ;;
        --stake_amount) # two-parameter argument, e.g. `--stake_amount 10gwei`
            shift
            stake_amount=$1 
            shift
            ;;
        --new_game) # creates a new game from the non-default accounts
            new_game=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

echo "Deploying with arguments:"
echo "--create=\t$create 
--setup=\t$setup
--new_accounts=\t$new_accounts
--fund_accounts=\t$fund_accounts
--fund_amount=\t$fund_amount
--stake_amount=\t$stake_amount
--new_game=\t$new_game

"


################# Set global ETH configuration #################

# Set environment variables used by the commands `forge` and `cast`
export ETH_RPC_URL="http://localhost:8545"
# keystore is generated everytime `dapp testnet` is called
export ETH_KEYSTORE=~/.dapp/testnet/8545/keystore/$(ls ~/.dapp/testnet/8545/keystore)
# better error trace when running cast
export RUST_BACKTRACE=full

################# Get default address into an env variable #################

# use jq to retrieve the json key "address", but it returns with double quotes
addressStr=$(cat $ETH_KEYSTORE | jq '.address')
# remove the double quotes and prepend 0x so that it is a valid address
DefaultAddress=0x$(sed -e 's/^"//' -e 's/"$//' <<< $addressStr)
echo "Default Address: $DefaultAddress"
export ETH_FROM=$DefaultAddress

################# Create contracts in the blockchain #################

# Create contract Token()
TokenFilename="$dir/create/TokenDeployment"
if [ "$create" = true ]; then
    echo "Creating Token.sol into $TokenFilename"
    forge create src/Token.sol:Token --password "" > $TokenFilename
fi
TokenAddress=$(zsh $dir/address_of.sh $TokenFilename)
echo "Token Address: $TokenAddress"

# Create contract NFT()
NFTFilename="$dir/create/NFTDeployment"
if [ "$create" = true ]; then
    echo "Creating NFT.sol into $NFTFilename"
    forge create src/NFT.sol:NFT --password "" > $NFTFilename
fi
NFTAddress=$(zsh $dir/address_of.sh $NFTFilename)
echo "NFT Address: $NFTAddress"

# Create contract TicTacToken(tokenAddr, NFTAddr)
TTTFilename="$dir/create/TTTDeployment"
if [ "$create" = true ]; then
    echo "Creating TicTacToken.sol into $TTTFilename"
    forge create src/TicTacToken.sol:TicTacToken --constructor-args $TokenAddress $NFTAddress --password "" > $TTTFilename
fi
TTTAddress=$(zsh $dir/address_of.sh $TTTFilename)
echo "TTT Address: $TTTAddress"

################# Proceeding to execute initial configuration #################

# set TicTacToken address on NFT
TxNFTSetTTTFilename="$dir/tx/Tx0_NFTSetTTT"
if [ "$setup" = true ]; then
    # uses ETH_FROM
    echo "Configuring NFT.setTTT(TicTacToken) into $TxNFTSetTTTFilename"
    cast send  --password "" $NFTAddress "setTTT(address)" $TTTAddress --rpc-url $ETH_RPC_URL > $TxNFTSetTTTFilename
fi

# Transfer NFT ownership to TicTacToken
TxNFTOwnershipTransferFilename="$dir/tx/Tx1_NFTOwnershipTransfer"
if [ "$setup" = true ]; then
    echo "Configuring NFT.transferOwnership(TicTacToken) into $TxNFTOwnershipTransferFilename"
    cast send --password "" $NFTAddress "transferOwnership(address)" $TTTAddress --rpc-url $ETH_RPC_URL > $TxNFTOwnershipTransferFilename
fi

# Transfer token owner to TicTacToken
TxTokenOwnershipTransferFilename="$dir/tx/Tx2_TokenOwnershipTransfer"
if [ "$setup" = true ]; then
    echo "Configuring Token.transferOwnership(TicTacToken) into $TxTokenOwnershipTransferFilename"
    cast send --password "" $TokenAddress "transferOwnership(address)" $TTTAddress --rpc-url $ETH_RPC_URL > $TxTokenOwnershipTransferFilename
fi

################# Create new accounts and their private keys #################
if [ "$new_accounts" = true ]; then
    # uses the `ethers` and `crypto` JS packages to create the file `address_env.sh` 
    echo "Creating new accounts from private keys under $dir/address_env.sh"
    node $dir/address > $dir/address_env.sh
fi

################# Fund accounts whose private key we control #################

source $dir/address_env.sh
echo "Mock Address 1: $ETH_ADDRESS_1"
echo "Mock Address 1 - key: $ETH_ADDRESS_KEY_1"
echo "Mock Address 2: $ETH_ADDRESS_2"
echo "Mock Address 2 - key: $ETH_ADDRESS_KEY_2"

TxFunding1="$dir/tx/Funding1"
TxFunding2="$dir/tx/Funding2"
if [ "$fund_accounts" = true ]; then
    echo "Funding $fund_amount to $ETH_ADDRESS_1 into $TxFunding1"
    cast send $ETH_ADDRESS_1 --value $fund_amount --password "" > $TxFunding1
    echo "Funding $fund_amount to $ETH_ADDRESS_2 into $TxFunding2"
    cast send $ETH_ADDRESS_2 --value $fund_amount --password "" > $TxFunding2
fi

################# Join game with accounts we control #################
TxNewGame1="$dir/tx/Tx_NewGame1"
TxNewGame2="$dir/tx/Tx_NewGame2"
if [ "$new_game" = true ]; then
    # create a game as X and stake
    echo "Creating a new game from $ETH_ADDRESS_1 with $stake_amount into $TxNewGame1"
    cast send --from $ETH_ADDRESS_1 --private-key $ETH_ADDRESS_KEY_1 $TTTAddress "newGameAsX()(uint256)" --value $stake_amount > $TxNewGame1
    # stake and join game 0
    echo "Joining game 0 from $ETH_ADDRESS_2 with $stake_amount into $TxNewGame2"
    cast send --from $ETH_ADDRESS_2 --private-key $ETH_ADDRESS_KEY_2 $TTTAddress "stakeAndJoin(uint256)" 0 --value $stake_amount > $TxNewGame2
fi

echo "Done."