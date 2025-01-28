function getErrorBody(err, mode) {
    if (err?.body?.message) {
        return {
            title: 'Error!',
            message: `${err.body.message}`,
            variant: 'error',
            mode
        }
    } else if (err?.body) {
        return {
            title: 'Error!',
            message: `${err.body}`,
            variant: 'error',
            mode
        }
    } else if (err?.message) {
        return {
            title: 'Error!',
            message: `${err.message}`,
            variant: 'error',
            mode
        }
    }
    return {
        title: 'Error!',
        message: `${err}`,
        variant: 'error',
        mode
    }
}

export {getErrorBody}