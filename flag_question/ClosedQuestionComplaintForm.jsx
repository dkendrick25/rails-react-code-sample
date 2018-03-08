import React from 'react'
import PropTypes from 'prop-types'

const ClosedQuestionComplaintForm = ({ onClick }) => (
  <button className='button button--primary btn-block' onClick={() => onClick('open')}>
    Flag The Question Above
  </button>
)

ClosedQuestionComplaintForm.propTypes = {
  onClick: PropTypes.func.isRequired
}

export default ClosedQuestionComplaintForm