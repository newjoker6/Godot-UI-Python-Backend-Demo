import asyncio
import websockets
import json
import matplotlib.pyplot as plt
import os

async def websocket_server(websocket, path):
    pid = os.getpid()
    await websocket.send(f"pid: {pid}")
    async for message in websocket:
        data = json.loads(message)
        print(f"Received message: {message}")

        if data["arg1"] == "graph":

            await websocket.send("This is a graph")
            plt.plot(data["arg2"], data["arg3"])
            plt.title(data["arg4"])
            plt.show()

        else:
            await websocket.send("Unrecognized data")

        # Process the message received from Godot
        # Perform actions based on the received data


start_server = websockets.serve(websocket_server, "localhost", 8765)
print("WebSocket server started")

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

