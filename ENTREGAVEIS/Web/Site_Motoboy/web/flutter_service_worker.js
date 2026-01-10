'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "5beedbbf4ad9af2812516d6060aaefc6",
"assets/AssetManifest.bin.json": "46a00613c1379a9488fb6d41c5df40dd",
"assets/assets/icon/loja2.png": "d0bdfe68336a32362a723407987ef27e",
"assets/assets/logocarlinho1.PNG": "322470cc3b4324acf0da9ffc41cbb852",
"assets/assets/produtos/1000.png": "64adce19c89fcd8319d7ced722974d37",
"assets/assets/produtos/1001.png": "b4afe36858604c0a2f87488f9faf87bb",
"assets/assets/produtos/1002.png": "f50fe61f03b5a005a2e60daa1e396d0e",
"assets/assets/produtos/1003.png": "d6cb1f5f05d9472c4f161648a2b92a41",
"assets/assets/produtos/1004.png": "d14d6fc904437bd74e187f2b41056cc6",
"assets/assets/produtos/1006.png": "deb61e47139c82bc02d78f7c926e52cc",
"assets/assets/produtos/1008.png": "8d2680e94a110ee0295a219460db469f",
"assets/assets/produtos/1009.png": "8f57fee3fe9a26b18fa8546d3c909f53",
"assets/assets/produtos/1010.png": "0eb7f892b4ccb3d421e8eec4869e1196",
"assets/assets/produtos/1012.png": "06f1766063fa62309842d2f6a45a51c7",
"assets/assets/produtos/1013.png": "c95c0ceeaf70cdc67e85a669e8257315",
"assets/assets/produtos/1015.png": "969eb6c10d6081642fe18982adbf2ca4",
"assets/assets/produtos/1016.png": "1b3d2544e94a944443b39d843ed2c8c9",
"assets/assets/produtos/1017.png": "6e85c11bd25c3781d6bdbeee2261bcfd",
"assets/assets/produtos/1018.png": "382e2498ccfc7c50da49bcec07d71791",
"assets/assets/produtos/1019.png": "9a2fd7468cbd1444fae285cc4db85558",
"assets/assets/produtos/1020.png": "c4772b45c47c98be02e2a1ec074421dd",
"assets/assets/produtos/1021.png": "c4772b45c47c98be02e2a1ec074421dd",
"assets/assets/produtos/1023.png": "6fc4729b77f990b23242f788ec4a26d5",
"assets/assets/produtos/1026.png": "4d8e79368be67d083d308f2e1a7f9fc1",
"assets/assets/produtos/1028.png": "bad3f9a79718aece477bc1291b1d5ff1",
"assets/assets/produtos/1030.png": "2f465d077a14d40480dc143311480aa9",
"assets/assets/produtos/1031.png": "c2a8edfc65ce84aa03195c975e60891e",
"assets/assets/produtos/1035.png": "2ec904332148af98e4402b16e4a89787",
"assets/assets/produtos/1038.png": "59546b1409f859e5d73788a6372a3481",
"assets/assets/produtos/1041.png": "1af92f7b7b63a10dd3ed5f55f1d759bb",
"assets/assets/produtos/1043.png": "c7536d4d72c0bda0277517e955f859e0",
"assets/assets/produtos/1044.png": "65638a51cdf88d47a685f31a3faf254f",
"assets/assets/produtos/1045.png": "948093acae967c7caa9d7db6cf27c40d",
"assets/assets/produtos/1047.png": "42c6e6571058dace9dffedf54e55cd4f",
"assets/assets/produtos/1051.png": "719fc18879c4d4b79ae39710fdae7dbd",
"assets/assets/produtos/1054.png": "9a56daebef64065a8ef5674441841671",
"assets/assets/produtos/1056.png": "417dad0f78f8c809203ea38178377e4f",
"assets/assets/produtos/1059.png": "9f7f0a35f52d1ad27a88e651e37ac4b0",
"assets/assets/produtos/643.png": "c54de45bd2f609a4fbb46821e6005feb",
"assets/assets/produtos/644.png": "66479a3c4e0da758ea16a45452d432ef",
"assets/assets/produtos/645.png": "51566dc6d307d4ac14cb2eb46d4ba789",
"assets/assets/produtos/646.png": "c47f06ce7cacbdca1827b7df74727092",
"assets/assets/produtos/647.png": "c12861b3dd15f434d6bcc26793fa8253",
"assets/assets/produtos/648.png": "d4c067306777a0089535075488844e66",
"assets/assets/produtos/649.png": "d63c231cba22a2cb71375eb5fd16af48",
"assets/assets/produtos/650.png": "27ba73e403997aa9e02301b2d8f4ecd3",
"assets/assets/produtos/651.png": "ab7ddd4afb78f526d5e9e0d71feb6300",
"assets/assets/produtos/653.png": "b986387e484405a160b44b60052ee270",
"assets/assets/produtos/654.png": "ad4848b6e0534d49ef4e00782ada1312",
"assets/assets/produtos/656.png": "cf9c6ffca6dbada252ce9912b2959242",
"assets/assets/produtos/658.png": "a7868f2d9e94432b6961b6ee7d7ed0da",
"assets/assets/produtos/659.png": "31953826a5bc5aef5000e0e26d8f5255",
"assets/assets/produtos/661.png": "b303927114fa958142d2fd44b7a5f61d",
"assets/assets/produtos/662.png": "b1fc70161d31647b42f891f56d288c3a",
"assets/assets/produtos/663.png": "c0a1aaeef3f69639aa5e87408e2ca823",
"assets/assets/produtos/664.png": "95b5687522afac6af714db5fe55e637d",
"assets/assets/produtos/665.png": "fcc5fe6a50b222ab50e6366fb1c35d35",
"assets/assets/produtos/666.png": "657f41696a2aa45c5af8ac9efbe9c803",
"assets/assets/produtos/670.png": "ae89c7554b0c9526672d90d96f5ac610",
"assets/assets/produtos/671.png": "ae89c7554b0c9526672d90d96f5ac610",
"assets/assets/produtos/673.png": "4c293d98f92dbf46d6c2e6071ad85497",
"assets/assets/produtos/674.png": "55e84ea4645ae763279d38033729b610",
"assets/assets/produtos/675.png": "0c81f9de26afbfc75c008ee8b2285774",
"assets/assets/produtos/676.png": "b7da162958637aae397c77ef1fdbc176",
"assets/assets/produtos/678.png": "1e0f19153434eed213afd83dbc11956d",
"assets/assets/produtos/680.png": "1de330959184311c47ef7536ad9debfd",
"assets/assets/produtos/682.png": "09b1120b6e0968608e516580dcab4a86",
"assets/assets/produtos/683.png": "d1fed67a54eb4cb29b0efc4e3180e90a",
"assets/assets/produtos/684.png": "a4735c2ab4c7026a8b5c6efdf9a4db85",
"assets/assets/produtos/685.png": "8a4d747f415d54af47f0fef30e3e16f7",
"assets/assets/produtos/686.png": "525e32579d03363129d37efd83b263a4",
"assets/assets/produtos/687.png": "f9b6f927c02d9974a19a4e49f0aeb056",
"assets/assets/produtos/688.png": "c11e9a9c6d73fc564ecd630b588186fa",
"assets/assets/produtos/689.png": "3cd025bb56a46a809d668e8e30e8e9c4",
"assets/assets/produtos/690.png": "613b4d755f61d5a05e62076d83ec63ec",
"assets/assets/produtos/691.png": "0e5a102ee867e80672a992a991f7a5b2",
"assets/assets/produtos/692.png": "ccc868ce82f08f7ead491c11bbfa1ec6",
"assets/assets/produtos/693.png": "c15a627f60658904c338b2e87756597c",
"assets/assets/produtos/696.png": "bb4d0d75f016e087f7ae4e482dd9d035",
"assets/assets/produtos/697.png": "4222994b33ba00fd820ca86d38bbe28f",
"assets/assets/produtos/698.png": "29e8f7990ae0190eef9d3ad47ae5ad86",
"assets/assets/produtos/699.png": "5fe88d80e741e12132fcb53e300694af",
"assets/assets/produtos/700.png": "5fe88d80e741e12132fcb53e300694af",
"assets/assets/produtos/701.png": "5ac7f10169d7003a86d78227aa4b4354",
"assets/assets/produtos/702.png": "99f0fa5fee4c619f9a99b2a043d13600",
"assets/assets/produtos/704.png": "4750bae8aedfd08322d1f14dc7a8d115",
"assets/assets/produtos/705.png": "5d3a0baa19441649d26de28114faa174",
"assets/assets/produtos/706.png": "4d4a2f8dd8644e96c55e9510e225d14e",
"assets/assets/produtos/707.png": "5a877cba2e9cdd3a50b15a159806f89d",
"assets/assets/produtos/709.png": "bdb5a7d713fb4e2096b905771b1e328a",
"assets/assets/produtos/710.png": "fb4b300308cc7a90f2345e63d12c34f2",
"assets/assets/produtos/714.png": "c603505ca1e8e46ba8f4713d3099ad5b",
"assets/assets/produtos/715.png": "a11b9572907de0765660bde32ac02d75",
"assets/assets/produtos/716.png": "d9d2c0487f1166bd50f24e7a10e9b450",
"assets/assets/produtos/717.png": "29bc3007ecf86c3ed090256284c59087",
"assets/assets/produtos/721.png": "e119ea25b6f437ec493f9faaf4af66e2",
"assets/assets/produtos/722.png": "49a0d0cdd148e54c7073517316407bf2",
"assets/assets/produtos/723.png": "e93ce78a87372eed95b25e262b47dfe9",
"assets/assets/produtos/725.png": "ad2c83341a71aa740ded7ef36c96f6c3",
"assets/assets/produtos/726.png": "3895dd2df4ab716b9bc3b6b252f85ec6",
"assets/assets/produtos/728.png": "ad2c83341a71aa740ded7ef36c96f6c3",
"assets/assets/produtos/729.png": "91aef142e3b0d4d69722bf1ebaa13686",
"assets/assets/produtos/732.png": "bfd52bab65b726ad7183faa7a71e2fae",
"assets/assets/produtos/733.png": "70619b190408b699022e836edb44be82",
"assets/assets/produtos/734.png": "57ed2978955abe06ebcf3a6b36160b66",
"assets/assets/produtos/738.png": "2eb162d6dab72f7f7af25896fd660574",
"assets/assets/produtos/739.png": "e5a748d27efd728342e69144fe966dd4",
"assets/assets/produtos/741.png": "7fd44bb12be6dd473cfd54e51da802da",
"assets/assets/produtos/742.png": "c4ecd3db9d4dd8112532f010e4f50fe1",
"assets/assets/produtos/743.png": "23fa379459af49c33a664774f46ca750",
"assets/assets/produtos/744.png": "895a8bdc93fcff73827f88e9862bf0fa",
"assets/assets/produtos/747.png": "00114c5511ca106ba5a4180349533ae8",
"assets/assets/produtos/748.png": "e17121da73632e103077421b2376988d",
"assets/assets/produtos/749.png": "19d3c0c61bb175dc41467bcd3ab684ac",
"assets/assets/produtos/750.png": "1c46562f14b453420a65da26e19499d9",
"assets/assets/produtos/751.png": "7f74c4d0b3dc879aae318c1283fe3841",
"assets/assets/produtos/752.png": "ad2c83341a71aa740ded7ef36c96f6c3",
"assets/assets/produtos/753.png": "0a7ff68cc3ddd08189344d8b5316ced3",
"assets/assets/produtos/754.png": "0a7ff68cc3ddd08189344d8b5316ced3",
"assets/assets/produtos/755.png": "d3f45d6819a345ce976802be01078a6a",
"assets/assets/produtos/757.png": "60bcdef321aaf6d14cb273ef2239fb92",
"assets/assets/produtos/758.png": "f16aa73990fea15b8ea42f0f6c45c57a",
"assets/assets/produtos/759.png": "ca2e52603acd9a700ba44ce14f3f2cb5",
"assets/assets/produtos/760.png": "62a76a14a6b17f61ff6d0b53d0cdbe7f",
"assets/assets/produtos/761.png": "62a76a14a6b17f61ff6d0b53d0cdbe7f",
"assets/assets/produtos/762.png": "db44c2eebf6b004e78b45145acb7bec9",
"assets/assets/produtos/763.png": "db44c2eebf6b004e78b45145acb7bec9",
"assets/assets/produtos/764.png": "7475bf2281532e1cf30bcc8350fbe865",
"assets/assets/produtos/765.png": "9660255268e01f4404775af017f4cd80",
"assets/assets/produtos/767.png": "36c068fc872f9776842a722d6b88e515",
"assets/assets/produtos/768.png": "ff6fa8cab11b2283513eca7f2747e228",
"assets/assets/produtos/770.png": "050002976d8220cdc04180161af3b67d",
"assets/assets/produtos/774.png": "f70c6a04a1fcddeffba943084ce5ee42",
"assets/assets/produtos/775.png": "d7abf0e2854781da349360a43a3bce43",
"assets/assets/produtos/776.png": "d972164b02774db2f06f9be970857c35",
"assets/assets/produtos/777.png": "7102bee63b79579010b8ce35f8892236",
"assets/assets/produtos/781.png": "f3b1e205b2eeadb426fef5a8dc902d3a",
"assets/assets/produtos/782.png": "4841bddcc21c7a0123a9c18b81d68b8a",
"assets/assets/produtos/783.png": "e709eb1416eda79e933dd0f56913fe0c",
"assets/assets/produtos/784.png": "067dc6dd44908dc565935be7f1b0e84a",
"assets/assets/produtos/785.png": "007b8564c99db8a954d9064213b99c2a",
"assets/assets/produtos/786.png": "6a8637c02f18166e4a5d2a2977831711",
"assets/assets/produtos/787.png": "d9110b67b8f41325f64a7cb01c3a18e8",
"assets/assets/produtos/789.png": "c3488c72baa3012a265814eb6a91bc13",
"assets/assets/produtos/791.png": "a6fdeb2be550fd8bdda40967f47b924d",
"assets/assets/produtos/792.png": "81f764dcf7f6a996d3b795e9d1894f2b",
"assets/assets/produtos/794.png": "400b1c400aa8be341e4345bc5dff8050",
"assets/assets/produtos/796.png": "e05c3662a921147a276e7fb0fb0022fc",
"assets/assets/produtos/797.png": "a0c270a5b6031b76abbf8ce30a925c3b",
"assets/assets/produtos/799.png": "b24c178dbced381cb0bc3142860d6f94",
"assets/assets/produtos/800.png": "db1f71a942b76a721148e82910afc507",
"assets/assets/produtos/801.png": "fdac5d805bdecec2e04f01d49396e20b",
"assets/assets/produtos/807.png": "a1b093d4ee3fe50d071757feaaf76c03",
"assets/assets/produtos/811.png": "9943e99f19399843aa2bce44f9dd2442",
"assets/assets/produtos/812.png": "a936cc856dd2add40693fe96cea0b973",
"assets/assets/produtos/813.png": "ecb85e808e7409fa3bdaa204e90bc4a3",
"assets/assets/produtos/815.png": "e0bae9bc0015f52e3498dd120283d4bc",
"assets/assets/produtos/816.png": "9578f1ca35f416d410ae59a272987c9b",
"assets/assets/produtos/817.png": "99d49f1f733167df82bbf7da85f349a7",
"assets/assets/produtos/818.png": "c171f9482835205a5dcb175940976027",
"assets/assets/produtos/819.png": "a9c33e46d3445f8c3e9c3b071925cbfe",
"assets/assets/produtos/823.png": "6766960b8f03c2ba1213f970e728affa",
"assets/assets/produtos/824.png": "97c2db44bc64d67c2ade82f7fc89a4ae",
"assets/assets/produtos/825.png": "60e69d3626132f00b396282a41fa98ac",
"assets/assets/produtos/826.png": "4af9b95e8bf7e54587b4fd8bb7b151a4",
"assets/assets/produtos/827.png": "1d90c2e616914fa1c1d47cecbbc487b3",
"assets/assets/produtos/828.png": "8ba33aa74fb12f69cbef55373fc65ef4",
"assets/assets/produtos/829.png": "3357acbe52903a02a78f68388ae27416",
"assets/assets/produtos/830.png": "dcb8c10d8e40c0a06b8a061efb360d8f",
"assets/assets/produtos/831.png": "7b5fb27f6da1d4fab3115de2f3b11e19",
"assets/assets/produtos/833.png": "afdba02592849ea7a34f787c4b60e44f",
"assets/assets/produtos/834.png": "4786a2376a82575918e05152cf38ccf5",
"assets/assets/produtos/835.png": "935d13d144cc950216f2753d035e3660",
"assets/assets/produtos/836.png": "3c0fd95ec2008ecebee2811ff423412c",
"assets/assets/produtos/837.png": "c1d16adaf9fa557dcc29f61af6320786",
"assets/assets/produtos/838.png": "1d8cf7fe998881e181254118d4bd3f5d",
"assets/assets/produtos/843.png": "8908e473b46fd1b28fd721149506c3eb",
"assets/assets/produtos/844.png": "4bebe178716a64f086c46951c8ff1e1b",
"assets/assets/produtos/845.png": "f0fb0257b6f62744233d560a7c5b1fe1",
"assets/assets/produtos/846.png": "501ae7f5791ecc31fc242a35b17f72c2",
"assets/assets/produtos/847.png": "16a78e09abfd6a31628e6f4755882bce",
"assets/assets/produtos/848.png": "18289924eabc98c7f58e767131280e2c",
"assets/assets/produtos/852.png": "b07b336ebed1e8f6aff5227153def120",
"assets/assets/produtos/854.png": "795f865869527465f117f8af9c97be92",
"assets/assets/produtos/856.png": "402727be40f10290a2eec319121f5830",
"assets/assets/produtos/859.png": "cc83ac84d36360378d7faa98b7068666",
"assets/assets/produtos/860.png": "1ff384c51137a463b9166419c44eb909",
"assets/assets/produtos/863.png": "534b4677fe24d09ce86e76912c616290",
"assets/assets/produtos/864.png": "b69151a9022069c68bb7514a3dd93bad",
"assets/assets/produtos/865.png": "e65fd00639d0f1230899ff6a0e5e0d57",
"assets/assets/produtos/869.png": "4c7cec27b861afe4a59be0f9a2224a8c",
"assets/assets/produtos/871.png": "56ba7b3499c930d8887c73b47f824014",
"assets/assets/produtos/872.png": "db953af1453c9cba0b1557b011a6f607",
"assets/assets/produtos/875.png": "5e8d137b95174730b3caa90dfa9e481c",
"assets/assets/produtos/876.png": "84bbaab0a9a941014db0194ab3864116",
"assets/assets/produtos/881.png": "87ef59b87dc627a14483c6287823d08b",
"assets/assets/produtos/887.png": "f2b55df66044967f98cb84ceb82cda78",
"assets/assets/produtos/889.png": "e9cd83c8382c5d0e09a3d20768ba3b05",
"assets/assets/produtos/890.png": "15acf1bcb1e20dcd91bffc8b907ce3b9",
"assets/assets/produtos/892.png": "15acf1bcb1e20dcd91bffc8b907ce3b9",
"assets/assets/produtos/893.png": "cd3d013d1d61655bd222b567911db40a",
"assets/assets/produtos/894.png": "d101a7b651173acc4396a61d9eed80fb",
"assets/assets/produtos/895.png": "823c25ff7fbd65e78b4d0f8c6931965f",
"assets/assets/produtos/896.png": "773292303d73812a8439f6c57e4436f7",
"assets/assets/produtos/900.png": "377e46d969511ba5abca5f26911dc815",
"assets/assets/produtos/901.png": "441881072b0df475fab660bc4aa190ba",
"assets/assets/produtos/902.png": "b4f9ffd6fd81448b4b0a2b38e109d4ea",
"assets/assets/produtos/903.png": "039a0dbe870bd2f8799feb3d854fe8ad",
"assets/assets/produtos/906.png": "0dd19794769c2a3fc0de1f50387d91a4",
"assets/assets/produtos/911.png": "8ba8329e0ce30ab3095dc5944c4ab80b",
"assets/assets/produtos/912.png": "f9b6f927c02d9974a19a4e49f0aeb056",
"assets/assets/produtos/913.png": "a33dacf670f91b5bcd10fcf58402f737",
"assets/assets/produtos/914.png": "a33dacf670f91b5bcd10fcf58402f737",
"assets/assets/produtos/915.png": "a33dacf670f91b5bcd10fcf58402f737",
"assets/assets/produtos/916.png": "a33dacf670f91b5bcd10fcf58402f737",
"assets/assets/produtos/917.png": "a33dacf670f91b5bcd10fcf58402f737",
"assets/assets/produtos/918.png": "a33dacf670f91b5bcd10fcf58402f737",
"assets/assets/produtos/920.png": "886f8ae58154072812ec06a18041a9fe",
"assets/assets/produtos/921.png": "886f8ae58154072812ec06a18041a9fe",
"assets/assets/produtos/922.png": "96055075d2da90d8c4efb3968408f8b7",
"assets/assets/produtos/924.png": "d972164b02774db2f06f9be970857c35",
"assets/assets/produtos/925.png": "d972164b02774db2f06f9be970857c35",
"assets/assets/produtos/926.png": "e85a66188ac47ccce27d20f1ee601936",
"assets/assets/produtos/928.png": "7b1e454f1245ae81bee36fc0b35e4f14",
"assets/assets/produtos/929.png": "2b8c688b8d16f8fc0add24322ba98158",
"assets/assets/produtos/930.png": "985b78840de90bbe8def7f883a296e53",
"assets/assets/produtos/932.png": "935d13d144cc950216f2753d035e3660",
"assets/assets/produtos/933.png": "935d13d144cc950216f2753d035e3660",
"assets/assets/produtos/934.png": "935d13d144cc950216f2753d035e3660",
"assets/assets/produtos/935.png": "935d13d144cc950216f2753d035e3660",
"assets/assets/produtos/936.png": "8816f845efe442e0733fc3804ad64a7c",
"assets/assets/produtos/937.png": "8816f845efe442e0733fc3804ad64a7c",
"assets/assets/produtos/938.png": "fcc5fe6a50b222ab50e6366fb1c35d35",
"assets/assets/produtos/939.png": "fcc5fe6a50b222ab50e6366fb1c35d35",
"assets/assets/produtos/940.png": "baf7fa282d140a27e08cc526e4ee7ae7",
"assets/assets/produtos/941.png": "baf7fa282d140a27e08cc526e4ee7ae7",
"assets/assets/produtos/942.png": "f38a59eecd7bf82f602f27af85474852",
"assets/assets/produtos/944.png": "35287896edbe82099b5b6a630126d995",
"assets/assets/produtos/945.png": "151d8ef1190f2e1856610d39f182eaca",
"assets/assets/produtos/946.png": "4d1d9768384295c729598dd96fcfc1c1",
"assets/assets/produtos/947.png": "4d1d9768384295c729598dd96fcfc1c1",
"assets/assets/produtos/950.png": "fad9eafe6f38705cf3a45387591af476",
"assets/assets/produtos/951.png": "ca98280c43c6ba286ea6681818643a11",
"assets/assets/produtos/952.png": "a11b9572907de0765660bde32ac02d75",
"assets/assets/produtos/954.png": "f877ec136e587b6c668bd51300034c98",
"assets/assets/produtos/956.png": "8a62961aa7ab6c2259a920fd358d9e39",
"assets/assets/produtos/957.png": "02b366ee36030e6b58f1ee3ccab30c52",
"assets/assets/produtos/965.png": "94bc98e1dada5888387a93f8517b84b2",
"assets/assets/produtos/967.png": "6d890ddf4229f3bdaaf8d2f9c7f64749",
"assets/assets/produtos/968.png": "9f5e2284e8201ca9f7831852b658d9ec",
"assets/assets/produtos/972.png": "efc81e68e9f88c9f7341f16297b80ac8",
"assets/assets/produtos/973.png": "77afc9d11d9f8a1ff0db74644c2bdfd5",
"assets/assets/produtos/976.png": "e2792458c22808fca85371938cdd6dc9",
"assets/assets/produtos/977.png": "a2fe71b999dda2c47e997f2daa95accc",
"assets/assets/produtos/978.png": "a2fe71b999dda2c47e997f2daa95accc",
"assets/assets/produtos/983.png": "75f12d22c3570950af9e347ea62d1dd1",
"assets/assets/produtos/984.png": "b986387e484405a160b44b60052ee270",
"assets/assets/produtos/986.png": "7ac4a083d197ca833ddfb0221794b62c",
"assets/assets/produtos/987.png": "7102bee63b79579010b8ce35f8892236",
"assets/assets/produtos/988.png": "62a76a14a6b17f61ff6d0b53d0cdbe7f",
"assets/assets/produtos/989.png": "44674c746d39d1d5ab2e1ec759d22181",
"assets/assets/produtos/990.png": "baf7fa282d140a27e08cc526e4ee7ae7",
"assets/assets/produtos/991.png": "1499a9709cf6ff31379059b70924e20c",
"assets/assets/produtos/992.png": "4d8e79368be67d083d308f2e1a7f9fc1",
"assets/assets/produtos/993.png": "b5c001cd3369f4e8f3435c4a3ee1fc8e",
"assets/assets/produtos/995.png": "00bb3f6b511dac7e14c1c948a015ee11",
"assets/assets/produtos/996.png": "35287896edbe82099b5b6a630126d995",
"assets/assets/produtos/998.png": "35287896edbe82099b5b6a630126d995",
"assets/assets/produtos/999.png": "64adce19c89fcd8319d7ced722974d37",
"assets/FontManifest.json": "c75f7af11fb9919e042ad2ee704db319",
"assets/fonts/MaterialIcons-Regular.otf": "ef788c9ce61d98554b28f3f3b1b6ff14",
"assets/NOTICES": "3e3757b770c33556a53d52ff92f5c168",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "d40c67ce9f52d4bf087e61453006393c",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "b2703f18eee8303425a5342dba6958db",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "5b8d20acec3e57711717f61417c1be44",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "672140bd0d1230d78268828f2dd98612",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "186d1d189f05d630b83628580dc36a5f",
"/": "186d1d189f05d630b83628580dc36a5f",
"main.dart.js": "54fcb2f4aa8ad478899deed73c0b6a1c",
"manifest.json": "83766976e56ed4151c02ab433bacb259",
"version.json": "c939345a701e26a3e7523daf33931bc8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
