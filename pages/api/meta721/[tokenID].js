const handler = async (req, res) => {
    const { tokenID } = req.query
    console.log(tokenID)
    res.json({
        'name': 'OpenSea Creature Accessories',
        'description': "Fun and useful accessories for your OpenSea creatures.",
        'image': 'https://miro.medium.com/max/446/0*jr7S0JF8XiousKKz.png',
        'external_link': 'https://github.com/ProjectOpenSea/opensea-erc1155/',
        'attributes': [
            {
                'trait_type': "等级",
                "value": "化神"
            },
            {
                'trait_type': "种类",
                "value": "52"
            },
            {
                'trait_type': "总数",
                "value": "229"
            },
            {
                'trait_type': "刷新区块",
                "value": "36326956"
            }
        ]
    })
}
export default handler;