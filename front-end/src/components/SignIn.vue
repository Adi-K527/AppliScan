<template>
  <div class="container">
    <h1 class="form-title">Sign In</h1>
    <form @submit.prevent="handleSignIn">
      <div class="input-group">
        <i class="fas fa-envelope"></i>
        <input v-model="email" type="email" placeholder="Email" required>
        <label for="email">Email</label>
      </div>
      <div class="input-group">
        <i class="fas fa-lock"></i>
        <input v-model="password" type="password" placeholder="Password" required>
        <label for="password">Password</label>
      </div>
      <p v-if="signInError" style="color: red;">{{ signInError }}</p>
      <p class="recover">
        <a @click="$emit('changeView', 'RecoverPassword')">Recover Password</a>
      </p>
      <input type="submit" class="btn" value="Sign In">
    </form>
    <p class="or">
      --------or------
    </p>
    <div class="icons">
      <i class="fab fa-google"></i>
      <i class="fab fa-facebook"></i>
    </div>
    <div class="links">
      <p>Don't have an account yet?</p>
      <button @click="$emit('changeView', 'SignUp')">Sign Up</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      email: '',
      password: '',
      signInError: ''
    }
  },
  methods: {
    handleSignIn() {
      // regex and checking
      if (!this.email.includes('@')) {
        this.signInError = "Email must contain @.";
        return;
      }
      
      
      this.signInError = "";
      // what to do after submission
    }
  }
}
</script>

<style scoped>

.container {
  background: #1e1e1e;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  width: 300px;
  margin: 20px 0;
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

input::placeholder {
  color: transparent;
}

input.error {
  border-color: red;
  color: red;
}
</style>
