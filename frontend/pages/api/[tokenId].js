export default function handler(req, res) {
    const tokenId = req.query.tokenId;

    const name = `Crypto Dev #${tokenId}`;
    const description = "Crypto Dev is a collection of developers in crypto";
    const image = `https://raw.githubusercontent.com/abhirajthakur/nft-collection-cryptodevs/main/frontend/public/cryptodevs/${Number(tokenId) - 1}.svg`;
    res.status(200).json({
        name: name,
        description: description,
        image: image,
    });
}