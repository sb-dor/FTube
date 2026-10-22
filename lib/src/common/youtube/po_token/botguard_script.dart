/// Page-side helper that runs YouTube's BotGuard and mints PO tokens.
///
/// Follows the flow of LuanRT/BgUtils (MIT): load the interpreter, start the program, take a
/// snapshot that fills `webPoSignalOutput`, then mint tokens with the integrity token.
const botGuardScript = r'''
window.ftubeBotGuard = window.ftubeBotGuard || {
  run: async function (challenge) {
    new Function(challenge.interpreterJavascript)();
    const vm = globalThis[challenge.globalName];
    if (!vm || typeof vm.a !== 'function') throw new Error('BotGuard VM not found');
    let asyncSnapshot = null;
    vm.a(challenge.program, function (snapshot) { asyncSnapshot = snapshot; }, true, undefined,
      function () {}, [[], []]);
    for (let i = 0; !asyncSnapshot && i < 2000; i++) {
      await new Promise(function (resolve) { setTimeout(resolve, 5); });
    }
    if (!asyncSnapshot) throw new Error('BotGuard did not start');
    const webPoSignalOutput = [];
    const response = await new Promise(function (resolve) {
      asyncSnapshot(resolve, [undefined, undefined, webPoSignalOutput, undefined]);
    });
    this.webPoSignalOutput = webPoSignalOutput;
    this.minter = null;
    return response;
  },
  setIntegrityToken: function (base64) {
    this.integrityToken = this.fromBase64(base64);
    this.minter = null;
    return 'ok';
  },
  mint: async function (identifier) {
    if (!this.minter) {
      const getMinter = this.webPoSignalOutput && this.webPoSignalOutput[0];
      if (!getMinter) throw new Error('PMD:Undefined');
      this.minter = await getMinter(this.integrityToken);
      if (!(this.minter instanceof Function)) throw new Error('APF:Failed');
    }
    const result = await this.minter(new TextEncoder().encode(identifier));
    if (!result) throw new Error('YNJ:Undefined');
    if (!(result instanceof Uint8Array)) throw new Error('ODM:Invalid');
    return this.toBase64(result);
  },
  fromBase64: function (value) {
    const binary = atob(value.replace(/-/g, '+').replace(/_/g, '/').replace(/\./g, '='));
    return Uint8Array.from(binary, function (c) { return c.charCodeAt(0); });
  },
  toBase64: function (bytes) {
    let binary = '';
    for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_');
  },
};
''';
