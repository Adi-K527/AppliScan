<template>
  <div id="app">
    <component :is="currentView" @changeView="handleChangeView"></component>
  </div>
</template>

<script>
import SignIn from './components/SignIn.vue'
import RecoverPassword from './components/RecoverPassword.vue'
import SignUp from './components/SignUp.vue'
import UserDashboard from './components/UserDashboard.vue'

export default {
  name: 'App',
  components: {
    SignIn,
    RecoverPassword,
    SignUp,
    UserDashboard
  },
  data() {
    return {
      currentView: 'SignIn'
    }
  },
  methods: {
    handleChangeView(view) {
      this.currentView = view;
    }
  }
}
</script>

<style>
body {
    font-family: Arial, sans-serif;
    background-color: #121212;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
    flex-direction: column; /* Stack elements vertically */
}

.container {
    background: #1e1e1e;
    padding: 2em;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    width: 300px;
    margin: 20px 0; /* Add margin for spacing between containers */
    text-align: center;
}

.form-title {
    margin-bottom: 1em;
    font-size: 24px;
    color: #ffffff;
}

.input-group {
    position: relative;
    margin-bottom: 1.5em;
}

.input-group i {
    position: absolute;
    top: 50%;
    left: 10px;
    transform: translateY(-50%);
    color: #888;
}

.input-group input {
    width: 90%;
    padding: 10px 10px 10px 35px;
    border: 1px solid #444;
    border-radius: 4px;
    outline: none;
    background-color: #2c2c2c;
    color: #ffffff;
}

.input-group input:focus {
    border-color: #1e88e5;
}

.input-group label {
    position: absolute;
    left: 35px;
    top: 50%;
    transform: translateY(-50%);
    color: #888;
    pointer-events: none;
    transition: 0.3s ease all;
}

.input-group input:focus + label,
.input-group input:not(:placeholder-shown) + label {
    top: -10px;
    left: 10px;
    color: #1e88e5;
    font-size: 12px;
}

.btn {
    width: 100%;
    padding: 10px;
    background: #1e88e5;
    border: none;
    border-radius: 4px;
    color: #fff;
    cursor: pointer;
    font-size: 16px;
}

.btn:hover {
    background: #1565c0;
}

.or {
    margin: 1em 0;
    color: #888;
}

.icons {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-bottom: 1em;
}

.icons i {
    font-size: 24px;
    color: #888;
    cursor: pointer;
}

.links {
    text-align: center;
}

.links p {
    margin: 0.5em 0;
    color: #888;
}

.links button,
.links a {
    background: none;
    border: none;
    color: #1e88e5;
    cursor: pointer;
    text-decoration: underline;
}

.links button:hover,
.links a:hover {
    color: #1565c0;
}

.recover {
    text-align: right;
    margin: 0.5em 0;
}

.recover a {
    color: #1e88e5;
    text-decoration: none;
}

.recover a:hover {
    text-decoration: underline;
}

input::placeholder {
    color: transparent;
}
input.error {
    border-color: red;
    color: red;
}


</style>
