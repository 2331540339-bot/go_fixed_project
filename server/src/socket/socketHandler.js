const onlineMechanics = {};
const RescueRequest = require("../app/models/RescueRequest");
const User = require("../app/models/User");
function socketInit(io) {
  io.on("connection", (socket) => {
    // Người dùng đăng ký nhận thông báo
    socket.on("subscribe_user", (userID) => {
      socket.join(userID);
      console.log("User joined room:", userID);
    });
    // Thợ đăng ký trực tuyến
    socket.on("subcribe_mechanic", async (mechanicID) => {
      onlineMechanics[mechanicID.mechanicID] = socket.id;
      console.log("3", socket.id);
      await User.findByIdAndUpdate(
        { _id: mechanicID.mechanicID },
        {
          $set: { status: "online" },
        }
      );
      socket.join("mechanicID.mechanicID");
      socket.emit("result_subcribe", {
        message: "You are online now",
      });
    });
    // Thợ nhận yêu cầu cứu hộ
    socket.on('accept_rescue_request', async ({ mechanicId, requestId }) => {
        const request = await RescueRequest.findByIdAndUpdate(requestId, {
            mechanic_id: mechanicId,
            status: "accepted",
        });
        io.to(request.user_id).emit("accepted-status-rescue", {message: 'Thợ đã chấp nhận yêu cầu của bạn'})
    })
   

    // Xử lý khi thợ ngắt kết nối
    socket.on("disconnect", async () => {
      for (const key in onlineMechanics) {
        if (onlineMechanics[key] === socket.id) {
          delete onlineMechanics[key];
          await User.findByIdAndUpdate(
            { _id: key },
            {
              $set: { status: "offline" },
            }
          );
          socket.emit("result_subcribe", {
            message: "You are offline",
          });
        }
      }
    });
  });
}
module.exports = {
  socketInit,
  onlineMechanics,
};
