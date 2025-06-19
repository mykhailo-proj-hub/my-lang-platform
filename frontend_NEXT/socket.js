// socket.js
import { io } from 'socket.io-client';

let socket;

export const initSocket = (onError) => {
  if (socket) return;

  socket = io('http://localhost:5000', {
    auth: {
      token: localStorage.getItem('jwt')
    },
    withCredentials: true,
    autoConnect: true,
    reconnection: true,
    reconnectionAttempts: 5,
    reconnectionDelay: 1000,
  });

  socket.on('connect_error', (err) => {
    console.error('❌ Socket connection error:', err.message);

    if (err.message?.includes('jwt') || err.message?.includes('token')) {
      if (typeof onError === 'function') onError(err);
    }
  });

  return socket;
};

export const getSocket = () => socket || null;

export const disconnectSocket = () => {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
};
