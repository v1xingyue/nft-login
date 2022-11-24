const handler = async (req, res) => {
    const { tokenID } = req.query
    console.log(tokenID)
    res.json({
        'name': 'OpenSea Creature Accessories',
        'description': "Fun and useful accessories for your OpenSea creatures.",
        'image': 'https://avatars.githubusercontent.com/u/974169',
        'external_link': 'https://github.com/ProjectOpenSea/opensea-erc1155/'
    })
}
export default handler;