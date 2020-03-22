'use strict';
const views = require('co-views');
const parse = require('co-body');
const messages = [{
    id: 0,
    message: 'Koa next generation web framework for node.js'
  },
  {
    id: 1,
    message: 'Koa is a new web framework designed by the team behind Express'
  }
];

const render = views(__dirname + '/../views', {
  map: {
    html: 'swig'
  }
});

const home = (ctx) => {
  ctx.body = render('list', {
    'messages': messages
  });
}

const list = (ctx) => {
  ctx.body = messages;
}

const fetch = (ctx) => {
  const message = messages[ctx.params.id];
  if (!message) {
    ctx.throw(404, 'message with id = ' + id + ' was not found');
  }
  ctx.body = message;
}

const create = (ctx) => {
  const message = parse(ctx.request.body);
  const id = messages.push(message) - 1;
  message.id = id;
  ctx.redirect('/');
}

const asyncOperation = () => callback =>
  setTimeout(
    () => callback(null, 'this was loaded asynchronously and it took 2 seconds to complete'),
    2000);

const returnsPromise = () =>
  new Promise((resolve, reject) =>
    setTimeout(() => resolve('promise resolved after 2 seconds'), 2000));

const delay = (ctx) => {
  ctx.body = asyncOperation();
}

const promise = (ctx) => {
  ctx.body = returnsPromise();
}

module.exports = {
  home,
  list,
  fetch,
  create,
  delay,
  promise
}
