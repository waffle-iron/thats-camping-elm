var path = require("path");
var AppCachePlugin = require('appcache-webpack-plugin');
var GitRevisionPlugin = require('git-revision-webpack-plugin');
var webpack = require('webpack');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var gitRevisionPlugin = new GitRevisionPlugin();

// TODO: Extract css into separate file because currently it's in the big js
// file and when that changes everything has to be reloaded

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname + '/docs'),
    filename: '[name].js',
  },

  module: {
    rules: [
      {
        test: /\.(css|scss)$/,
        loader: ExtractTextPlugin.extract({
          fallbackLoader: 'style-loader',
          loader: "css-loader",
        })
      },
      {
        test:    /\.(html|png)$/,
        exclude: /node_modules/,
        use:  'file-loader?name=[name].[ext]',
      },
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use:  'elm-webpack-loader?verbose=true&warn=true',
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        use: 'url-loader?limit=10000&mimetype=application/font-woff',
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        use: 'file-loader',
      },
    ],

    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
    stats: { colors: true },
  },

  plugins: [
    new AppCachePlugin({}),
    new GitRevisionPlugin(),
    new webpack.DefinePlugin({
      'VERSION': JSON.stringify(gitRevisionPlugin.version())
    }),
    new ExtractTextPlugin('app.css')
  ]
};
