import React, { Component } from 'react';
import { observer } from "mobx-react";
import Web3 from 'web3'

class NFTLogin extends Component {

  constructor(props) {
    super(props)
    this.state = {
      wallet: "",
      chain: null,
      contract: "",
      connected: false,
      message: "Login With Chaoverse NFT.",
      nfts: [],
      loading: "",
    }
    this.web3utils = new Web3(Web3.givenProvider).utils
  }

  async componentDidMount() {
    try {
      const chain = await ethereum.request({ method: 'eth_chainId' });
      this.setState({ chain })
    } catch (e) {
      if (!ethereum) return alert('Please install metamask')
    }
  }

  connectWallet = async () => {
    if (!ethereum) return console.error('Please install metamask')
    try {
      const connected = await ethereum.request({ method: 'eth_requestAccounts' })
      if (connected && Array.isArray(connected) && connected.length > 0) {
        this.setState({
          wallet: connected[0],
          connected: true
        })
      } else {
        console.error('NFT LOGIN => fail wallet connect ', connected);
      }
    } catch (e) {
      console.error("NFT LOGIN => connect wallet e", e)
    }
  }

  fetchNFTs = async (e) => {

    if (e && e.preventDefault) e.preventDefault()
    const { connected } = this.state
    if (!connected) {
      const connection = await this.connectWallet()
      if (!connection) return console.error('NFT LOGIN => connection to wallet failed')
    }
    const { message, wallet, chain, contract } = this.state
    const web3 = new Web3(Web3.givenProvider);
    const nonce = message
    let signature = await web3.eth.personal.sign(nonce, wallet, "log in")

    this.setState({
      loading: "animate-bounce"
    })

    let res = await fetch(`/api/nfts?${new URLSearchParams({ contract, wallet, chain, nonce, signature })}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    })
    res = await res.json()
    this.setState({
      loading: ""
    })
    if (res.success && Array.isArray(res.nfts)) {
      this.setState({ nfts: res.nfts, count: res.totalCount })
    }
  }

  render() {
    const { chain, wallet, nfts, count, loading } = this.state
    return (
      <div className="p-16">
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
        <div className="pt-8">
          {!wallet && (
            <button
              type="button"
              onClick={this.connectWallet}
              className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Connect Wallet
            </button>
          )}
          {wallet && (
            <div>
              <div className="bg-white shadow sm:rounded-lg">
                <div className="px-4 py-5 sm:p-6">
                  <h3 className="text-lg leading-6 font-medium text-gray-900">Get Chaoverse NFTs</h3>
                  <form onSubmit={this.fetchNFTs} className="mt-5 flex flex-col justify-start items-start w-full" >
                    <button
                      type="submit"
                      className={loading + " inline-flex items-center justify-center px-4 py-2 border border-transparent shadow-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"}
                    >
                      Fetch My Chaoverse NFTs
                    </button>
                  </form>
                </div>
              </div>
            </div>
          )}
          <ul role="list" className="pt-8 grid grid-cols-2 gap-x-4 gap-y-8 sm:grid-cols-3 sm:gap-x-6 lg:grid-cols-4 xl:gap-x-8">
            {nfts.length > 0 && nfts.map(nft => (
              <li key={`${nft.contract.address}-${nft.id.tokenId}`} className="relative">
                <div className="group block w-full aspect-w-10 aspect-h-7 rounded-lg bg-gray-100 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-offset-gray-100 focus-within:ring-indigo-500 overflow-hidden">
                  {nft?.media?.length > 0 && nft.media.map(m => (<img key={m.raw} src={m.gateway} className="w-full object-contain pointer-events-none group-hover:opacity-75" />))}
                  <p>{nft.balance}</p>
                  <button type="button" className="absolute inset-0 focus:outline-none">
                    <span className="sr-only">View details for {nft.title}</span>
                  </button>
                </div>
                <p className="mt-2 block text-sm font-medium text-gray-900 truncate pointer-events-none">{nft.title} </p>
                <p className="block text-sm font-medium text-gray-500 pointer-events-none">{nft.description}</p>
                <div >
                </div>
              </li>
            ))}
          </ul>
          {nfts.length > 0 && (
            <p className="pt-6 text-sm">Showing {nfts.length} of {count} total</p>
          )}
        </div>
      </div>
    )
  }
}

NFTLogin.propTypes = {

}

export default observer(NFTLogin);
