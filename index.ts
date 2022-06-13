import lambdafs from "lambdafs";

const inflate = async () => {
    const browserPath = await lambdafs.inflate(`${__dirname}/package/webkit/webkit.tar.br`)
    console.log({
        browserPath
    })
}

inflate();
// console.log(__dirname);
