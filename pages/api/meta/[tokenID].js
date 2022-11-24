const handler = async (req, res) => {
    const { tokenID } = req.query
    res.json({
        "name": "hello",
        "description": "hello world",
        "image": "https://ipfs.io/ipfs/bafkreifvhjdf6ve4jfv6qytqtux5nd4nwnelioeiqx5x2ez5yrgrzk7ypi",
        "tokenID": tokenID,
    })
}
export default handler;