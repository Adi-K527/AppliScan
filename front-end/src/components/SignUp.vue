<template>
  <div class="container">
    <h1 class="form-title">Register</h1>
    <form @submit.prevent="handleSignUp">
      <div class="input-group">
        <i class="fas fa-user"></i>
        <input v-model="firstName" type="text" placeholder="First Name" required>
        <label for="fname">First Name</label>
      </div>
      <div class="input-group">
        <i class="fas fa-user"></i>
        <input v-model="lastName" type="text" placeholder="Last Name" required>
        <label for="Lname">Last Name</label>
      </div>
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
      <div class="input-group">
        <i class="fas fa-lock"></i>
        <input v-model="confirmPassword" type="password" placeholder="Confirm Password" required>
        <label for="confirmPassword">Confirm Password</label>
      </div>
      <p v-if="signUpError" style="color: red;">{{ signUpError }}</p>
      <input type="submit" class="btn" value="Sign Up">
    </form>
    <p class="or">
      --------or------
    </p>
    <div class="icons">
      <i class="fab fa-google"></i>
      <i class="fab fa-facebook"></i>
    </div>
    <div class="links">
      <p>Already Have Account! Sign with these</p>
      <button @click="$emit('changeView', 'SignIn')">Sign In</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      firstName: '',
      lastName: '',
      email: '',
      password: '',
      confirmPassword: '',
      signUpError: ''
    }
  },
  methods: {
    async handleSignUp() {
      const specialCharacterRegex = /[!@#$%^&*(),.?":{}|<>]/;
  
      if (this.password !== this.confirmPassword) {
        this.signUpError = "Passwords do not match.";
        return;
      }
  
      if (this.password.length < 4) {
        this.signUpError = "Password must be at least 4 characters long.";
        return;
      }
  
      if (!specialCharacterRegex.test(this.password)) {
        this.signUpError = "Password must contain at least one special character.";
        return;
      }
  
      if (!this.email.includes('@')) {
        this.signUpError = "Email must contain @.";
        return;
      }
  
      
      this.signUpError = ""; // if any error mess
  
      // Preparation to post
      const payload = {
        firstName: this.firstName,
        lastName: this.lastName,
        email: this.email,
        password: this.password
      };
  
      try { // post req
        
        console.log(process.env.VUE_APP_BACKEND_URL);
        const response = await fetch(`${process.env.VUE_APP_BACKEND_URL}/signup`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
  
        const data = await response.json();
  
        if (response.ok) {
          console.log('User signed up:', data.user);
          this.$emit('changeView', 'SignIn'); // redirect to sign in view
          
        } else {
          this.signUpError = data.error;
        }
      } catch (error) {
        console.error('Error signing up:', error);
        this.signUpError = 'An error occurred. Please try again.';
      }
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
