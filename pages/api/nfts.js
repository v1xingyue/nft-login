require("dotenv").config()
const ethUtil = require("ethereumjs-util");

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const GOERLI_ALCHEMY_API_URL = "https://polygon-mainnet.g.alchemy.com/v2/SCJ33Q4yqU2BaxI5s5klGg0pU9ArIKGn";
const MAINNET_ALCHEMY_API_URL = "https://mainnet.infura.io/v3/";

const handler = async (req, res) => {
  try {
    const contract = "0x2953399124f0cbb46d2cbacd8a89cf0599974963";
    const { key, wallet, chain, signature } = req.query
    let { nonce } = req.query
    if (!chain || !wallet || !signature || !nonce) return res.status(400).json({ error: 'invalid params' });
    let web3 = null

    // set up alchemy connection
    if (chain === '0x1') {
      web3 = createAlchemyWeb3(MAINNET_ALCHEMY_API_URL)
    } else if (chain === '0x5') {
      web3 = createAlchemyWeb3(GOERLI_ALCHEMY_API_URL)
    } else if (chain === '0x89') {
      web3 = createAlchemyWeb3(GOERLI_ALCHEMY_API_URL)
    } else {
      return res.json({ error: 'Chain not supported' })
    }

    // Make sure the signature is valid
    nonce = "\x19Ethereum Signed Message:\n" + nonce.length + nonce
    nonce = ethUtil.keccak(Buffer.from(nonce, "utf-8"))
    const { v, r, s } = ethUtil.fromRpcSig(signature)
    const pubKey = ethUtil.ecrecover(ethUtil.toBuffer(nonce), v, r, s)
    const addrBuf = ethUtil.pubToAddress(pubKey)
    const addr = ethUtil.bufferToHex(addrBuf)

    // fetch the nfts
    const _nfts = await web3.alchemy.getNfts({
      owner: addr,
      contractAddresses: [contract],
    })

    // match nfts to contract addresses (if any)
    const nfts = []
    _nfts.ownedNfts.forEach(nft => {
      if (nft.id.tokenId == "0x8e331eacd843b49f9f44cde57ba0c476eda91bb90000000000003100000003e8") {
        nfts.push(nft);
      }
      // console.log(nft, contract);
      // if (!contract) {
      //   nfts.push(nft)
      // } else {
      // if (contract.toLowerCase().split(',').indexOf(nft.contract.address.toLowerCase()) !== -1) {
      //   nfts.push(nft)
      // }
      // }
    })

    return res.json({ success: true, nfts, totalCount: _nfts.totalCount })
  } catch (e) {
    console.error('e ', e)
    return res.json({ error: 'Error' });
  }
}

export default handler