// Перевіряє, чи повідомлення має зміст і не є сміттям
module.exports = function isMessageValid(message) {
    const cleaned = message.trim().toLowerCase();
  
    const garbageRegex = /^(\p{P}|\p{S}|\s)*$/u;
    if (cleaned.length < 3 || garbageRegex.test(cleaned)) return false;
  
    const commonUseless = ['ok', 'okay', 'hmm', 'uh', 'yo', 'a', 'b', 'nope'];
    if (commonUseless.includes(cleaned)) return false;
  
    const repeatedChar = /^([a-zA-Zа-яА-ЯёЁ0-9.,!?])\1{2,}$/u;
    if (repeatedChar.test(cleaned)) return false;
  
    return true;
  };
  