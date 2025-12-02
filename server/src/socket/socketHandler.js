const onlineMechanics = {};
const RescueRequest = require("../app/models/RescueRequest");
const User = require("../app/models/User");
function socketInit(io) {
  io.on("connection", (socket) => {

    socket.on("subscribe_user", (userID) => {
      socket.join(userID);
      console.log("User joined room:", userID);
    });

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
        io.to(request.user_id).emit("accepted-status-rescue", {message: 'Thợ đã chấp nhận yêu cầu của bạn', requestID: request._id})
    })

    socket.on('send_location', ({mechanicLocation, user_id}) => {
       io.to(user_id).emit("mechanic_location", {mechanicLocation})
    })

    socket.on('finish_rescue', async({requestId}) => {
       const request = await RescueRequest.findByIdAndUpdate(requestId, {
            status: "finished",
        });

        io.to(request.user_id).emit("finish_rescue", {message: 'Đã hoàn thành yêu cầu cứu hộ', requestID: request._id})
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
