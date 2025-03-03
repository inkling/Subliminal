/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = (env, argv) => {
  if (argv.mode === 'development') {
    return {
      entry: './src/index.tsx',
      mode: 'development',
      output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist'),
      },
      resolve: {
        extensions: ['.tsx', '.ts', '.js'],
      },
      module: {
        rules: [
          {
            test: /\.(ts|tsx)$/,
            exclude: /node_modules/,
            use: 'babel-loader',
          },
          {
            test: /\.css$/i,
            use: ['style-loader', 'css-loader'],
          },
          {
            test: /\.(png|svg|jpg|jpeg|gif)$/i,
            type: 'asset/resource',
          },
        ],
      },
      plugins: [
        new HtmlWebpackPlugin({
          template: './src/index.html',
        }),
      ],
    };
  }

  return {
    entry: './src/index.ts',
    mode: 'production',
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, 'dist'),
      publicPath: '',
      chunkFilename: '[id].[chunkhash].js',
      library: {
        name: 'MagicBellClient',
        type: 'umd',
      },
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js'],
    },
    module: {
      rules: [
        {
          test: /\.(ts|tsx)$/,
          exclude: /node_modules/,
          use: 'ts-loader',
        },
        {
          test: /\.css$/i,
          use: ['style-loader', 'css-loader'],
        },
        {
          test: /\.(png|svg|jpg|jpeg|gif)$/i,
          type: 'asset/inline'
        },
      ],
    },

    externals: {
      react: 'react',
    },
  };
};
