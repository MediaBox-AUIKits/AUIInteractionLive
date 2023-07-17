function copyText() {
  const command = 'copy';
  const support = document.queryCommandSupported(command);
  const enable = document.queryCommandSupported(command);

  const defaultStyle = [
    'position: absolute;',
    'left: -10px; top: -10px;',
    'width: 0; height: 0;',
    'line-height: 0;',
    'opacity: 0;',
  ].join('');

  let copyTextarea: HTMLTextAreaElement;

  const init = () => {
    copyTextarea = document.createElement('textarea');
    copyTextarea.style.cssText = defaultStyle;
    document.body.appendChild(copyTextarea);
  };

  return (text: string) => {
    if (!support || !enable) {
      return false;
    }
    if (!copyTextarea) {
      init();
    }

    copyTextarea.value = text;
    copyTextarea.focus();
    copyTextarea.select();

    try {
      document.execCommand(command);
      return true;
    } catch (e) {
      return false;
    } finally {
      copyTextarea.value = '';
      copyTextarea.blur();
    }
  };
}

export default copyText();
