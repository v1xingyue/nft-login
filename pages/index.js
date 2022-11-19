import React, { useState, useEffect } from 'react';
import Web3 from 'web3'

const BasicHeader = ({ chain, wallet }) => {

  return (
    <div className="bg-white shadow overflow-hidden sm:rounded-lg">
      <div className="px-4 py-5 sm:px-6">
        <h3 className="text-lg leading-6 font-medium text-gray-900">Connection Information</h3>
      </div>
      <div className="border-t border-gray-200 px-4 py-5 sm:p-0">
        <dl className="sm:divide-y sm:divide-gray-200">
          <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Chain</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{chain}</dd>
          </div>
          <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Wallet</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              {wallet ? wallet : "disconnected"}
            </dd>
          </div>
        </dl>
      </div>
    </div>
  );
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

const OperateList = ({ wallet, callback, chain }) => {
  const message = "Fetch my Chaoverse NFTS!";
  let { setWallet, setNftData } = callback;
  const [loading, setLoading] = useState("");
  return (
    <>
      {!wallet && (
        <button
          type="button"
          onClick={async () => {
            console.log("...");
            const connect = await connectWallet();
            if (connect.error == null) {
              setWallet(connect.wallet);
            }
          }}
          className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Connect Wallet
        </button>
      )}

      {wallet && (
        <button
          type="button"
          onClick={async () => {
            setLoading("animate-bounce");
            let nftData = await fetchNFTs({ wallet, message, chain })
            setNftData(nftData);
            setLoading("");
          }}
          className={loading + " inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"}
        >
          Fetch My Chaoverse NFTs
        </button>
      )}

    </>

  )
}

const NftList = ({ nfts, count }) => {
  return (
    <>
      <ul role="list" className="pt-8 grid grid-cols-2 gap-x-4 gap-y-8 sm:grid-cols-3 sm:gap-x-6 lg:grid-cols-4 xl:gap-x-8">
        {nfts.length > 0 && nfts.map(nft => (
          <li key={`${nft.contract.address}-${nft.id.tokenId}`} className="relative">
            <div className="group block w-full aspect-w-10 aspect-h-7 rounded-lg bg-gray-100 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-offset-gray-100 focus-within:ring-indigo-500 overflow-hidden">
              {nft?.media?.length > 0 && nft.media.map(m => (<img key={m.raw} src={m.gateway} className="w-full object-contain pointer-events-none group-hover:opacity-75" />))}
            </div>
            <p className="mt-2 block text-sm font-medium text-gray-900 truncate pointer-events-none">{nft.title} {nft.balance} </p>
            <p className="block text-sm font-medium text-gray-500 pointer-events-none">{nft.description}</p>
            <div >
            </div>
          </li>
        ))}
      </ul>
      {nfts.length > 0 && (
        <p className="pt-6 text-sm">Showing {nfts.length} of {count} total</p>
      )}
    </>
  );
}

export default () => {

  const [chain, setChainId] = useState("0x89");
  const [wallet, setWallet] = useState("");
  const [nftData, setNftData] = useState({ nfts: [], count: 0 });

  useEffect(() => {
    (async () => {
      document.title = "Chaoverse world";
      try {
        const chain = await ethereum.request({ method: 'eth_chainId' });
        setChainId(chain)
        ethereum.on('chainChanged', (chain) => {
          setChainId(chain);
          setWallet("");
        });
      } catch (e) {
        if (!ethereum) return alert('Please install metamask')
      }
    })();
  })

  return (
    <>
      <div className='p-16'>
        <BasicHeader chain={chain} wallet={wallet} />
        <div className="p-8">
          <OperateList wallet={wallet} chain={chain} callback={{ setWallet, setNftData }} />
        </div>
        <div className="p-8">
          <NftList nfts={nftData.nfts} count={nftData.count}></NftList>
        </div>
      </div>
    </>
  );
}
