const http = require("http");
const { Role, AccessToken } = require("@huddle01/server-sdk/auth");

const hostName = "127.0.0.1";
const port = 3000;

const server = http.createServer();
server.listen(port, hostName, async (req, res) => {
  try {
    const accessToken = new AccessToken({
      apiKey: "YOUR_API_KEY",
      roomId: "YOUR_ROOM_ID",
      //available roles: Role.HOST, Role.CO_HOST, Role.SPEAKER, Role.LISTENER, Role.GUEST - depending on the privileges you want to give to the user
      role: Role.HOST,
      //custom permissions give you more flexibility in terms of the user privileges than a pre-defined role
      permissions: {
        admin: true,
        canConsume: true,
        canProduce: true,
        canProduceSources: {
          cam: true,
          mic: true,
          screen: true,
        },
        canRecvData: true,
        canSendData: true,
        canUpdateMetadata: true,
      },
      options: {
        metadata: {
          // you can add any custom attributes here which you want to associate with the user
          walletAddress: "mizanxali.eth",
        },
      },
    });
    const token = await accessToken.toJwt();
    console.log(token);
  } catch (err) {
    console.log(err);
  }
});
