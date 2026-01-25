// Видаляє лапки з початку і кінця рядка
module.exports = function removeQuotes(text) {
    return text.trim().replace(/^["'“”‘’«»„‚‹›](.*?)[“”‘’"'\«»„‚‹›]$/, '$1');
  };