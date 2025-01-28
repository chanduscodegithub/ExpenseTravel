function getErrorBody(err) {
  if (err?.body?.message) {
    return {
      title: 'Error!',
      message: `${err.body.message}`,
      variant: 'error'
    }
  } else if (err?.body) {
    return {
      title: 'Error!',
      message: `${err.body}`,
      variant: 'error'
    }
  } else if (err?.message) {
    return {
      title: 'Error!',
      message: `${err.message}`,
      variant: 'error'
    }
  }
  return {
    title: 'Error!',
    message: `${err}`,
    variant: 'error'
  }
}

export { getErrorBody }