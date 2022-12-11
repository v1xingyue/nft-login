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
                'trait_type': "level",
                "value": "0"
            }
        ]
    })
}
export default handler;