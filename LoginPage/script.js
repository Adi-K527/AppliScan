const signUpButton = document.getElementById('signUpButton');
const signInButton = document.getElementById('signInButton');
const recoverPasswordButton = document.getElementById('recoverPasswordButton');
const backToSignInButton = document.getElementById('backToSignInButton');

const signInForm = document.getElementById('signIn');
const signUpForm = document.getElementById('signUp');
const recoverPasswordForm = document.getElementById('recoverPassword');

const signUpSubmit = document.getElementById('signUpSubmit');
const signUpPassword = document.getElementById('signUpPassword');
const signUpConfirmPassword = document.getElementById('signUpConfirmPassword');
const signUpError = document.getElementById('signUpError');

signUpButton.addEventListener('click', function() {
    signInForm.style.display = "none";
    signUpForm.style.display = "block";
    recoverPasswordForm.style.display = "none";
});

signInButton.addEventListener('click', function() {
    signUpForm.style.display = "none";
    signInForm.style.display = "block";
    recoverPasswordForm.style.display = "none";
});

recoverPasswordButton.addEventListener('click', function() {
    signUpForm.style.display = "none";
    signInForm.style.display = "none";
    recoverPasswordForm.style.display = "block";
});

backToSignInButton.addEventListener('click', function() {
    signUpForm.style.display = "none";
    signInForm.style.display = "block";
    recoverPasswordForm.style.display = "none";
});

function clearPlaceholder(input) {
    input.placeholder = input.dataset.originalPlaceholder;
    input.classList.remove('error');
}

signUpSubmit.addEventListener('click', function(event) {
    event.preventDefault(); // Prevent form submission
    
    const password = signUpPassword.value;
    const confirmPassword = signUpConfirmPassword.value;
    const specialCharacterRegex = /[!@#$%^&*(),.?":{}|<>]/;
    const email = document.getElementById('signUpEmail').value;

    const inputs = signUpForm.querySelectorAll('input[required]');
    for (let input of inputs) {
        if (input.value.trim() === '') {
            signUpError.innerHTML = `${input.dataset.originalPlaceholder} is required.`;
            signUpError.style.display = "block";
            input.placeholder = `${input.dataset.originalPlaceholder} is required.`;
            input.classList.add('error');
            return;
        } else {
            clearPlaceholder(input);
        }
    }

    // Email validation
    if (!email.includes('@')) {
        signUpError.innerHTML = "Email must contain @.";
        signUpError.style.display = "block";
        const emailInput = document.getElementById('signUpEmail');
        emailInput.classList.add('error');
        emailInput.placeholder = "Email must contain @.";
        return;
    }

    // Password confirmation
    if (password !== confirmPassword) {
        signUpError.innerHTML = "Passwords do not match.";
        signUpError.style.display = "block";
        signUpPassword.classList.add('error');
        signUpConfirmPassword.classList.add('error');
        signUpPassword.placeholder = "Passwords do not match.";
        signUpConfirmPassword.placeholder = "Passwords do not match.";
        return;
    }

    // Length of password
    if (password.length < 4) {
        signUpError.innerHTML = "Password must be at least 4 characters long.";
        signUpError.style.display = "block";
        signUpPassword.classList.add('error');
        signUpPassword.placeholder = "Password must be at least 4 characters long.";
        return;
    }

    // Special character
    if (!specialCharacterRegex.test(password)) {
        signUpError.innerHTML = "Password must contain at least one special character.";
        signUpError.style.display = "block";
        signUpPassword.classList.add('error');
        signUpPassword.placeholder = "Password must contain at least one special character.";
        return;
    }

    // If no errors, submit the form
    signUpError.style.display = "none";
    signUpForm.submit();
});

// Set the original placeholder as a data attribute to restore later
const requiredInputs = signUpForm.querySelectorAll('input[required]');
requiredInputs.forEach(input => {
    input.dataset.originalPlaceholder = input.placeholder;
    input.addEventListener('focus', function() {
        clearPlaceholder(input);
    });
});
