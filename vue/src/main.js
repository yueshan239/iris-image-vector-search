import Vue from 'vue'
import App from './App.vue'
import axios from 'axios'
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';

Vue.use(ElementUI);
Vue.prototype.$axios = axios
Vue.config.productionTip = false
Vue.prototype.$url = 'http://49.232.180.138:52773'


new Vue({
  render: h => h(App),
}).$mount('#app')
