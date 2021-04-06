const puppeteer = require('puppeteer');

(async () => {
    let options = {width: 1280, height: 1024};
    const browser = await puppeteer.launch({
        headless: false,
        defaultViewport: null,
        args: [`--window-size=${options.width},${options.height}`]
    });

    // open new tab
    // const page = await browser.newPage();

    // use default tab
    const page = (await browser.pages())[0];
    
    // uncomment when enable defaultViewport
    // await page.setViewport({
    //     width: options.width,
    //     height: options.height
    // });
    
    await page.goto('https://ya.ru/');
    try {
        await page.screenshot({ path: 'screen.png' })
    } catch(e) {
        console.log(e);
    }
    await browser.close();
})();