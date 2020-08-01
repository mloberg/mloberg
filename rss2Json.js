const fs = require('fs');
const Parser = require('rss-parser');
const parser = new Parser();

(async () => {
    const xml = fs.readFileSync('/dev/stdin').toString();
    const feed = await parser.parseString(xml);
    console.log(JSON.stringify(feed));
})();
