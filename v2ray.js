var qrcode = require('qrcode-terminal');
var fs = require('fs');
fs.readFile('sebs.js', 'utf8', function (err, data) {
  if (err) throw err;
     node = JSON.parse(data);
    console.log('-----------------iOS小火箭链接--------------------')
    console.log(ios(node).toString())
    console.log('-----------------安卓 v2rayNG链接-----------------')
    console.log(android(node).toString())
    console.log('-----------------Surgio Provider-----------------')
    console.log(surgio(node))
});

function ios(node) {
    !node.method ? node.method = 'chacha20-poly1305' : ''
    let v2rayBase = '' + node.method + ':' + node.id + '@' + node.add + ':' + node.port
    let remarks = ''
    // let obfsParam = ''
    let path = ''
    let obfs = ''
    let tls = ''
    !node.ps ? remarks = 'remarks=oneSubscribe' : remarks = `remarks=${node.ps}`
    !node.path ? '' : path = `&path=${node.path}`
    node.net == 'ws' ? obfs = `&obfs=websocket` : ''
    node.net == 'h2' ? obfs = `&obfs=http` : ''
    node.tls == 'tls' ? tls = `&tls=1` : ''
    let query = remarks + path + obfs + tls
    let baseV2ray = Buffer.from(v2rayBase).toString('base64')
    let server = Buffer.from('vmess://' + baseV2ray + '?' + query)
    return server
}

function android(node) {
    node.v = "2"
    // node.path = node.path.replace(/\//, '')
    delete node.method
    let baseV2ray = Buffer.from(JSON.stringify(node)).toString('base64')
    let server = Buffer.from('vmess://' + baseV2ray)
    return server
}

function surgio(node) {
    json = {
        nodeName: 'name',
        type: 'vmess',
        hostname: node.add,
        method: 'auto', // 仅支持 auto/aes-128-gcm/chacha20-ietf-poly1305/none
        network: 'ws', // 仅支持 tcp/ws
        alterId: '64',
        path: node.path,
        port: 443,
        tls: true,
        host: node.add,
        uuid: node.id,
        tfo: false, // TCP Fast Open
        tls13: false, // TLS 1.3, TLS 开启时有效
      }
    let server = JSON.stringify(json)
    return server
}

