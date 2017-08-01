// Copyright © 2017 Tim Nguyen, Jan Keromnes. All rights reserved.
// The following code is covered by the AGPL-3.0 license.

'use strict';

module.exports = function (options) {
  // Example: Remove the C runner
  // delete options.runners['C (simple)'];

  var config = require('../client-default')(options);
  var includes = [
    'plugins/c9.ide.janitorconfig/c9.ide.janitorconfig',
    'plugins/c9.ide.reviewcomments/c9.ide.reviewcomments',
    // 'plugins/c9.ide.desktop/c9.ide.desktop',
    // 'user-plugins/harvard.cs50.debug',
  ];
  var excludes = {
    // 'plugins/c9.ide.run/gui': true,
    // 'plugins/c9.ide.run/output': true,
  };

  config = config.concat(includes).map(function(p) {
    return (typeof p === 'string') ? { packagePath: p } : p;
  }).filter(function(p) {
    // Fix "Cloud9 > Go To Your Dashboard" link.
    if (p.dashboardUrl && p.dashboardUrl.includes('c9.io')) {
      p.dashboardUrl = 'https://janitor.technology/contributions/';
    }

    // Fix Cloud9 Account link.
    if (p.accountUrl && p.accountUrl.includes('c9.io')) {
      p.accountUrl = 'https://janitor.technology/settings/';
    }

    // See all packages: https://gist.github.com/nt1m/496072681cbfb64988313af5a4223da4#file-gistfile2-txt
    switch (p.packagePath) {
      case 'plugins/c9.core/c9':
        // TODO: fix p.hostname to 'janitor.technology' or 'moz1.janitor.technology'?
        break;

      case 'plugins/c9.ide.layout.classic/preload':
        break;

      case 'plugins/c9.core/settings':
        if (p.settings) {
          // Tweak the default user settings.
          // Examples:
          //   https://irccloud.mozilla.com/pastebin/a5dCP0qY/settings.user
          //   https://gist.github.com/viankakrisna/7efa1fecb13e3dabf944eac8f111af50
          if (!p.settings.user) {
            p.settings.user = {};
          }

          if (typeof p.settings.user === 'string') {
            p.settings.user = JSON.parse(p.settings.user);
          }

          if (!p.settings.user.ace) {
            p.settings.user.ace = {};
          }

          // Use the Monokai theme by default.
          p.settings.user.ace['@theme'] = 'ace/theme/monokai';

          // Use a bigger code editor font size by default.
          p.settings.user.ace['@fontSize'] = '14';

          if (!p.settings.user.terminal) {
            p.settings.user.terminal = {};
          }

          // Use a longer scrollback for the Terminal.
          p.settings.user.terminal['@scrollback'] = 10000;
        }
        break;
    }

    return !excludes[p.packagePath];
  });

  return config;
};
