'use strict';
const messages = require('./controllers/messages');
const compress = require('koa-compress');
const logger = require('koa-logger');
const serve = require('koa-static');
const Koa = require('koa');
const Router = require('koa2-router');
const path = require('path');
const app = module.exports = new Koa();

//app.use(logger());
//app.use(serve(path.join(__dirname, 'public')));
//app.use(compress());

// Routing
const router = new Router();
router.get('/', messages.home);
router.get('/messages', messages.list);
router.get('/messages/:id', messages.fetch);
router.post('/messages', messages.create);
router.get('/async', messages.delay);
router.get('/promise', messages.promise);

app.use(router);

if (!module.parent) {
  app.listen(3000);
  console.log('listening on port 3000');
}
