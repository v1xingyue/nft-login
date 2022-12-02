import Web3 from 'web3'
import MemberMeta from "./member";

const contractAddress = "0x0D58a00fF374642b94174AE444289cb39FC43eee";
const gasPrice = 43000000000;
const defaultDonate = Web3.utils.toBN("1000000000000000000");

const donate = async (wallet) => {
    const web3 = new Web3(Web3.givenProvider);
    let contract = new web3.eth.Contract(
        MemberMeta,
        contractAddress
    );
    return contract.methods.donate().send({
        from: wallet,
        value: defaultDonate,
        gas
    });
}

const refreshLevel = async (wallet) => {
    const web3 = new Web3(Web3.givenProvider);

    let contract = new web3.eth.Contract(
        MemberMeta,
        contractAddress
    );

    return contract.methods.refreshLevel().send({
        from: wallet,
        gasPrice
    });
}


const currentLevel = async (wallet) => {
    if (wallet != "") {
        console.log("load level for : ", wallet)
        const web3 = new Web3(Web3.givenProvider);
        let contract = new web3.eth.Contract(MemberMeta, contractAddress);
        return contract.methods.userLevels(wallet).call();
    } else {
        return { level: 0, expire: 0 };
    }
}

const fetchNFTs = async ({ message, wallet, chain, contract }) => {
    const web3 = new Web3(Web3.givenProvider);
    const nonce = message
    let signature = await web3.eth.personal.sign(nonce, wallet, "log in")
    let res = await fetch(`/api/nfts?${new URLSearchParams({ contract, wallet, chain, nonce, signature })}`, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    res = await res.json()
    if (res.success && Array.isArray(res.nfts)) {
        return { nfts: res.nfts, count: res.totalCount };
    }
}

const connectWallet = async () => {
    let result = {
        wallet: "",
        connected: false,
        error: null
    }
    if (!ethereum) {
        result.error = new Error("Please install metamask.");
    } else {
        try {
            const connected = await ethereum.request({ method: 'eth_requestAccounts' })
            if (connected && Array.isArray(connected) && connected.length > 0) {
                result.wallet = connected[0];
                result.connected = true;
                result.error = null;
            } else {
                console.error('NFT LOGIN => fail wallet connect ', connected);
                result.error = new Error("NFT LOGIN => fail wallet connect ");
            }
        } catch (e) {
            console.error("NFT LOGIN => connect wallet e", e)
            result.error = new Error("NFT LOGIN => fail wallet connect ");
        }
        return result;
    }
}

const levelText = (level) => {
    console.log("current level", level);
    switch (parseInt(level)) {
        case 0:
            return "加载中";
        case 1:
            return "练气";
        case 2:
            return "筑基";
        case 3:
            return "结丹";
        case 4:
            return "元婴";
        case 5:
            return "化神";
    }
}

export {
    connectWallet, fetchNFTs, currentLevel, refreshLevel, levelText, donate
}