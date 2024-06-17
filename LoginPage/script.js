const signUpButton = document.getElementById('signUpButton');
const signInButton = document.getElementById('signInButton');
const signInForm = document.getElementById('signIn');
const signUpForm = document.getElementById('signUp');
const signUpSubmit = document.getElementById('signUpSubmit');
const signUpPassword = document.getElementById('signUpPassword');
const signUpConfirmPassword = document.getElementById('signUpConfirmPassword');
const signUpError = document.getElementById('signUpError');

signUpButton.addEventListener('click', function() {
    signInForm.style.display = "none";
    signUpForm.style.display = "block";
});

signInButton.addEventListener('click', function() {
    signUpForm.style.display = "none";
    signInForm.style.display = "block";
});

signUpSubmit.addEventListener('click', function() {
    const password = signUpPassword.value;
    const confirmPassword = signUpConfirmPassword.value;
    const specialCharacterRegex = /[!@#$%^&*(),.?":{}|<>]/;
    
    // confirmation
    if (password !== confirmPassword) {
        signUpError.textContent = "Passwords do not match.";
        signUpError.style.display = "block";
        return;
    }

    //length of pass
    if (password.length < 4) {
        signUpError.textContent = "Password must be at least 4 characters long.";
        signUpError.style.display = "block";
        return;
    }

    // Special character
    if (!specialCharacterRegex.test(password)) {
        signUpError.textContent = "Password must contain at least one special character.";
        signUpError.style.display = "block";
        return;
    }

    // If it pass
    signUpError.style.display = "none";
    signUpForm.submit();
});
