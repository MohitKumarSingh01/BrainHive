import { useState, useEffect } from 'react';
// import { firestore } from '../lib/firebase';
import { useUser } from '@clerk/nextjs';
import { firestore } from '@/lib/firebase';


interface Message {
  id: string;
  text: string;
  createdAt: firebase.firestore.Timestamp;
  userEmail: string;
  userId: string;
  userName: string;
}

const Chat = () => {
  const { user } = useUser();
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    const unsubscribe = firestore
      .collection('messages')
      .orderBy('createdAt')
      .onSnapshot((snapshot:any) => {
        setMessages(
          snapshot.docs.map((doc:any) => ({ id: doc.id, ...doc.data() } as Message))
        );
      });

    return () => unsubscribe();
  }, []);

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim()) return;

    await firestore.collection('messages').add({
      text: message,
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      userEmail: user?.primaryEmailAddress?.emailAddress,
      userId: user?.id,
      userName: user?.fullName || user?.username,
    });

    setMessage('');
  };

  return (
    <div className="chat-container">
      <h2>Chat Room</h2>
      <div className="chat-messages">
        {messages.map((msg) => (
          <div key={msg.id} className={`chat-message ${msg.userId === user?.id ? 'self' : ''}`}>
            <strong>{msg.userName}</strong>: {msg.text}
          </div>
        ))}
      </div>
      <form onSubmit={sendMessage}>
        <input
          type="text"
          placeholder="Type a message..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
        />
        <button type="submit">Send</button>
      </form>
    </div>
  );
};

export default Chat;
