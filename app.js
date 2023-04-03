import { create } from 'ipfs-http-client';
import fetch from "node-fetch";
import https from "https";
import fs from 'fs';
// Login to infura.io and go to IPFS to create a project, after creating the project you will get the INFURA_SECRET_KEY and INFURA_ID set them here.
const INFURA_ID="2Np7iR6NoQwDpRffHt1obWRquWr";
const INFURA_SECRET_KEY="8bc34689eecdc653d9f4db3aa24935bb";
let res="";
const auth = 'Basic ' + Buffer.from(INFURA_ID + ':' + INFURA_SECRET_KEY).toString('base64');
const agent = new https.Agent({
    rejectUnauthorized: false
  });

async function ipfsClient() {
    const ipfs = await create(
        {
            host: "ipfs.infura.io",
            port: 5001,
            protocol: "https",
              headers: {
               authorization: auth, // infura auth credentails
           },
        }
    );
    // console.log("ipfs create--", ipfs);
    return ipfs;
}


async function saveText() {
    let ipfs = await ipfsClient();

    let result = await ipfs.add(`welcome ${new Date()}`);
    // let result = await ipfs.add("Hello World");
    console.log("Result -", result);
    console.log("Result path --", result["path"]);
    return result;
}
// res = await saveText();

async function saveFile() {

    let ipfs = await ipfsClient();

    let data = fs.readFileSync("3.PNG")
    // let data = "Hello"
    let options = {
        warpWithDirectory: false,
        progress: (prog) => console.log(`Saved :${prog}`)
    }
    let result = await ipfs.add(data, options);
    console.log(result)
    return result;
}

// res = await saveFile()


async function getData(hash) {
    let ipfs = await ipfsClient();

    let data1 = "https://ipfs.io/ipfs/"+hash.toString();
  console.log(data1);
    return  data1;
    // let asyncitr = ipfs.cat(hash)
    // console.log("result -- ",asyncitr);
    // let data="";
    // for await (const itr of asyncitr) {

    //     data = Buffer.from(itr).toString()
    //     // let data =itr.toString();
    //     console.log(data)
    // }

    console.log("In cipfs");
    const result = await ipfs.get(hash);
    console.log("out of", result);
     let data="";
      for await (const itr of result) {

            data += Buffer.from(itr).toString()
            // let data =itr.toString();
            
        }
        // console.log(data)
    // await ipfs.get(hash, (err, files) => {
    //     console.log("In function");
    //     if (err) {
    //       console.error(err);
    //     } else {
    //       // Save the image to file
    //       console.log("In else block");
    //       fs.writeFile('image.jpg', files[0].content, (err) => {
    //         if (err) throw err;
    //         console.log('Image saved to file!');
    //       });
    //     }
    //   });

    ipfs.get(hash)
        .then(file=> {
            console.log("in then")
            let data = file[0].content;
            console.log(data);
        })
       .catch(err => {
    console.error(err);
    });
// QmVNJk8gWcpE2SQk5xpiBw6xBhRhVLdDS8TXWsp5J9Sr1N
// getData(res["path"]);
}
getData("QmVNJk8gWcpE2SQk5xpiBw6xBhRhVLdDS8TXWsp5J9Sr1N");

