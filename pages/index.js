import React, { useState, useEffect } from 'react';
import { connectWallet, fetchNFTs, currentLevel, refreshLevel, levelText, donate } from "../chaoverse/operate.js";

const Card = () => {

    const [chain, setChainId] = useState("0x89");
    const [wallet, setWallet] = useState("");
    const [level, updateLevel] = useState({ level: "0", expire: 333333, totalCount: 0, uniqueCount: 0 });

    const doWalletConnect = async () => {
        const connect = await connectWallet();
        if (connect.error == null) {
            setWallet(connect.wallet);
        } else {
            console.log(connect.error);
        }
    }

    const doCurrentLevel = async () => {
        let level = await currentLevel(wallet);
        console.log("level : ", level);
        updateLevel({
            level: levelText(level.level),
            expire: level.expire,
            totalCount: level.totalCount,
            uniqueCount: level.uniqueCount
        })
    }

    useEffect(() => {
        if (wallet != "") {
            console.log("wallet changed ...");
            doCurrentLevel();
        }
    }, [wallet])

    useEffect(() => {
        (async () => {
            document.title = "Chaoverse 专属会员卡";
            try {
                const chain = await ethereum.request({ method: 'eth_chainId' });
                if (chain != '0x89') {
                    alert("请连接 Polygon 网络")
                }
                setChainId(chain)
                ethereum.on('chainChanged', (chain) => {
                    setChainId(chain);
                    setWallet("");
                    if (chain != '0x89') {
                        alert("请连接 Polygon 网络")
                    }
                });
                doWalletConnect();
            } catch (e) {
                if (!ethereum) return alert('Please install metamask')
            }
        })();
    });

    return (
        <div className="p-6 max-w-3xl h-80 mx-auto bg-white rounded-xl shadow-lg flex items-center space-x-5 space-y-3" >
            <div className="shrink-0 space-x-2">
                <img className="h-32 w-32 rounded-full" src="https://i.seadn.io/gae/1E9rCsB1C6w46y4jWTPZgy7q6Zv5Tff8QeM_9VihbmNzoXj5rclVVZy2nfKsfeA1BYNfKGqtc-KMLozBbCGeR2MzZQAGUJ8a6VaKnQ?auto=format&w=1000" alt="ChitChat Logo" />
            </div>
            <div className='h-32'>
                <div className="text-xl font-medium text-black">Chaoverse Level Card</div>
                <div>
                    <p className="text-slate-500 leading-loose">账户: {wallet} </p>
                    <p className="text-slate-500 leading-loose">等级: {level.level} </p>
                    <p className="text-slate-500 leading-loose space-x-3">
                        <span>
                            {level.uniqueCount}种
                        </span>
                        <span>
                            {level.totalCount}张
                        </span>
                        <span>
                            刷新区块:{level.expire - 32}
                        </span>
                    </p>

                </div>
                <div className="m-3 space-x-3">
                    <button onClick={doWalletConnect} className="px-4 py-1 text-sm text-purple-600 font-semibold rounded-full border border-purple-200 hover:text-white hover:bg-purple-600 hover:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-600 focus:ring-offset-2">连接钱包</button>
                    <button
                        onClick={async () => {
                            let levelData = await refreshLevel(wallet);
                            if (levelData.error) {
                                console.log(level.error);
                            } else {
                                await doCurrentLevel()
                            }
                        }}
                        className="px-4 py-1 text-sm text-purple-600 font-semibold rounded-full border border-purple-200 hover:text-white hover:bg-purple-600 hover:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-600 focus:ring-offset-2">刷新等级</button>
                    <button
                        onClick={async () => {
                            donate(wallet);
                        }}
                        className="px-4 py-1 text-sm text-purple-600 font-semibold rounded-full border border-purple-200 hover:text-white hover:bg-purple-600 hover:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-600 focus:ring-offset-2">捐赠</button>
                </div>

            </div>
        </div >
    )
}

export default Card;