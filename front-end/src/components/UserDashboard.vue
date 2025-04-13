<template>
  <div class="dashboard">
    <h1>Dashboard</h1>

    <!-- No Permission Case -->
    <div v-if="noPermission">
      <button class="btn" @click="grantPermissions">Grant Google Permissions</button>
    </div>

    <!-- Applications List -->
    <div v-else>
      <div v-if="applications.length">
        <div v-for="(app, index) in applications" :key="index" class="application-card">
          <p><strong>Company:</strong> {{ app.company }}</p>
          <p><strong>Status:</strong> {{ app.status }}</p>
        </div>
      </div>
      <div v-else>
        <p>No applications found.</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserDashboard',
  data() {
    return {
      applications: [],
      noPermission: false
    };
  },
  methods: {
    getAuthToken() {
      const match = document.cookie.match(/(?:^|;\s*)AUTH_TOKEN=([^;]*)/);
      return match ? match[1] : null;
    },
    async fetchApplications() {
      const token = this.getAuthToken();
      if (!token) {
        this.$emit('changeView', 'SignIn'); // redirect to login
        return;
      }

      try {
        const response = await fetch(`${process.env.VUE_APP_BACKEND_URL}/applications`, {
          method: "GET",
          headers: {
            Authorization: `Bearer ${token}`
          }
        });

        const data = await response.json();

        console.log(data)

        if (data.message === "NoPerm") {
          this.noPermission = true;
        } else {
          this.applications = data.users || [];
        }
      } catch (err) {
        console.error("Error loading applications:", err);
      }
    },
    grantPermissions() {
      console.log(process.env.VUE_APP_GMAIL_URL);
      window.location.href = `${process.env.VUE_APP_GMAIL_URL}/`; 
    }
  },
  mounted() {
    this.fetchApplications();
  }
};
</script>

<style scoped>
.dashboard {
  max-width: 600px;
  margin: 2rem auto;
  padding: 1rem;
  color: #fff;
}

.application-card {
  background: #2c2c2c;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  border: 1px solid #444;
}

.btn {
  padding: 10px 20px;
  background: #1e88e5;
  border: none;
  border-radius: 4px;
  color: #fff;
  cursor: pointer;
}

.btn:hover {
  background: #1565c0;
}
</style>
