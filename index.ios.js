/**
 * @providesModule RNShare
 * @flow
 */
'use strict';

var { NativeModules } = require('react-native');
var NativeRNShare = NativeModules.RNShare;
var invariant = require('invariant');

/**
 * High-level docs for the RNShare iOS API can be written here.
 */

var RNShare = {
  test: function() {
    NativeRNShare.test();
  },
  open: function(options, cb) {
  	NativeRNShare.open(options, cb);
  }
};

module.exports = RNShare;
